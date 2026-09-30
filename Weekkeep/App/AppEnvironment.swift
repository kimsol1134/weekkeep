import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class AppEnvironment {
    @ObservationIgnored let photoLibrary: any PhotoLibraryClient
    @ObservationIgnored let analysisService: any PhotoAnalysisService
    @ObservationIgnored let albumStore: any AlbumStore
    @ObservationIgnored let purchaseClient: any PurchaseClient
    @ObservationIgnored let notificationClient: any NotificationClient
    @ObservationIgnored let analyticsClient: any AnalyticsClient
    @ObservationIgnored let defaults: UserDefaults
    @ObservationIgnored let isFixture: Bool

    let weekCalculator: WeekRangeCalculator
    let entitlementPolicy = EntitlementPolicy()
    let appRouter = AppRouter()
    var selectedTab: AppTab = .week
    var shouldStartWelcomeCuration = false
    var pendingDeepLink: AppDeepLink?
    var pendingWeeklyEntryPoint: WeeklyEntryPointAnalyticsValue?
    var onboardingCompleted: Bool {
        didSet { defaults.set(onboardingCompleted, forKey: Keys.onboardingCompleted) }
    }

    private enum Keys {
        static let onboardingCompleted = "onboardingCompleted"
        static let regularCycleStartsAt = "regularCycleStartsAt"
        static let notificationPrimerShown = "notificationPrimerShown"
    }

    init(
        photoLibrary: any PhotoLibraryClient,
        analysisService: any PhotoAnalysisService,
        albumStore: any AlbumStore,
        purchaseClient: any PurchaseClient,
        notificationClient: any NotificationClient,
        analyticsClient: any AnalyticsClient,
        defaults: UserDefaults = .standard,
        isFixture: Bool = false,
        timeZone: TimeZone = .current
    ) {
        self.photoLibrary = photoLibrary
        self.analysisService = analysisService
        self.albumStore = albumStore
        self.purchaseClient = purchaseClient
        self.notificationClient = notificationClient
        self.analyticsClient = analyticsClient
        self.defaults = defaults
        self.isFixture = isFixture
        self.weekCalculator = WeekRangeCalculator(timeZone: timeZone)
        self.onboardingCompleted = defaults.bool(forKey: Keys.onboardingCompleted)
    }

    var regularCycleStartsAt: Date? {
        get { defaults.object(forKey: Keys.regularCycleStartsAt) as? Date }
        set { defaults.set(newValue, forKey: Keys.regularCycleStartsAt) }
    }

    var notificationPrimerShown: Bool {
        get { defaults.bool(forKey: Keys.notificationPrimerShown) }
        set { defaults.set(newValue, forKey: Keys.notificationPrimerShown) }
    }

    static func live(configuration: AppConfiguration = .bundle) -> AppEnvironment {
        let timeZone = TimeZone.current
        let photoLibrary = PhotoKitClient()
        let analysis = OnDevicePhotoAnalysisPipeline(
            photoLibrary: photoLibrary,
            timeZoneIdentifier: timeZone.identifier
        )
        let albumStore: any AlbumStore
        if let container = try? WeekkeepSchema.liveContainer() {
            albumStore = SwiftDataAlbumStore(modelContainer: container)
        } else {
            // Never silently replace durable storage with an in-memory store in
            // production. The UI must surface a recoverable local-storage error.
            albumStore = UnavailableAlbumStore()
        }

        let purchase: any PurchaseClient
        if configuration.hasValidPurchaseConfiguration {
            purchase = RevenueCatPurchaseClient(apiKey: configuration.revenueCatAPIKey)
        } else {
            purchase = DisabledPurchaseClient()
        }

        let notifications: any NotificationClient = LocalNotificationClient()

        let analytics: any AnalyticsClient
        if configuration.hasValidAnalyticsConfiguration {
            analytics = PostHogAnalyticsClient(
                projectToken: configuration.postHogProjectToken,
                host: configuration.postHogHost
            )
        } else {
            analytics = NoopAnalyticsClient()
        }

        return AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: analysis,
            albumStore: albumStore,
            purchaseClient: purchase,
            notificationClient: notifications,
            analyticsClient: analytics,
            timeZone: timeZone
        )
    }

#if DEBUG
    static func fixtures(purchaseState: EntitlementState = .inactive) -> AppEnvironment {
        let defaults = UserDefaults(suiteName: "weekkeep.fixtures") ?? .standard
        defaults.removePersistentDomain(forName: "weekkeep.fixtures")
        // A fixture app can be relaunched by several XCTest cases in one
        // runner process. Clear the known state keys explicitly as well as
        // the suite domain so a prior fixture screen cannot leak into the
        // next launch through UserDefaults caching.
        for key in ["onboardingCompleted", "regularCycleStartsAt", "notificationPrimerShown"] {
            defaults.removeObject(forKey: key)
        }
        if ProcessInfo.processInfo.arguments.contains("-ui-fixtures-skip-notification") {
            defaults.set(true, forKey: "notificationPrimerShown")
        }
        let fixtureCount = ProcessInfo.processInfo.environment["WK_UI_FIXTURE_PHOTO_COUNT"].flatMap(Int.init)
        let descriptors = fixtureCount.map { FixturePhotoLibraryClient.makeDescriptors(count: min(max($0, 0), 7)) }
        let fixtureScreen = ProcessInfo.processInfo.environment["WK_UI_FIXTURE_SCREEN"]
        let fixturePermission: PhotoAuthorization = fixtureScreen == "ready-limited" ? .limited : .authorized
        let photoLibrary = FixturePhotoLibraryClient(
            descriptors: descriptors ?? FixturePhotoLibraryClient.makeDescriptors(count: 42),
            permission: fixturePermission
        )
        let analysis = FixturePhotoAnalysisService(photoLibrary: photoLibrary)
        let albumStore: any AlbumStore
        if ["ready", "ready-empty", "ready-limited", "welcome-pending"].contains(fixtureScreen) {
            defaults.set(true, forKey: "onboardingCompleted")
            defaults.set(Date().addingTimeInterval(-14 * 24 * 60 * 60), forKey: "regularCycleStartsAt")
            if fixtureScreen == "ready" || fixtureScreen == "ready-limited" {
                let now = Date()
                let calculator = WeekRangeCalculator()
                let welcome = calculator.welcomeRange(analysisStartedAt: now)
                let photos = SamplePhotoFixtures.photos.enumerated().map { index, photo in
                    AlbumPhotoSnapshot(
                        id: UUID(),
                        assetLocalIdentifier: PhotoID("fixture-photo-\(index)"),
                        capturedAt: photo.capturedAt,
                        position: index,
                        source: .initial,
                        scoreSnapshot: photo.score,
                        isAvailable: true
                    )
                }
                let welcomeAlbum = WeeklyAlbumSnapshot(
                    id: UUID(),
                    weekKey: welcome.key,
                    kind: .welcome,
                    weekStart: welcome.start,
                    weekEnd: welcome.end,
                    analysisCutoff: welcome.cutoff,
                    createdAt: now,
                    updatedAt: now,
                    coverPhotoID: photos.first?.id,
                    photos: photos
                )
                defaults.set(now.addingTimeInterval(-14 * 24 * 60 * 60), forKey: "regularCycleStartsAt")
                albumStore = InMemoryAlbumStore(initialAlbums: [welcomeAlbum])
            } else {
                albumStore = InMemoryAlbumStore()
            }
        } else {
            albumStore = InMemoryAlbumStore()
        }
        return AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: analysis,
            albumStore: albumStore,
            purchaseClient: FixturePurchaseClient(state: purchaseState),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: defaults,
            isFixture: true
        )
    }
#endif

#if DEBUG
    /// A DEBUG-only screenshot environment backed by the bundled
    /// `SamplePhotoFixtures` through `FixturePhotoLibraryClient`. This is
    /// deterministic bundled-fixture UI evidence; it does not exercise
    /// PhotoKit. Production and distribution builds continue to use
    /// `AppEnvironment.live()` and the real PhotoKit adapter.
    static func appStoreScreenshotFixtures() -> AppEnvironment {
        let defaults = UserDefaults(suiteName: "weekkeep.app-store-screenshots") ?? .standard
        defaults.removePersistentDomain(forName: "weekkeep.app-store-screenshots")
        // The screenshot narrative must reach the real saved Weeks surface;
        // the ordinary fixture suite continues to cover the notification
        // primer separately.
        defaults.set(true, forKey: "notificationPrimerShown")

        let photoLibrary = FixturePhotoLibraryClient(
            descriptors: FixturePhotoLibraryClient.makeDescriptors(
                count: SamplePhotoFixtures.assetNames.count
            )
        )
        let analysis = AppStoreScreenshotFixtureAnalysisService(photoLibrary: photoLibrary)
        return AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: analysis,
            albumStore: InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: defaults,
            isFixture: true
        )
    }
#endif
}
