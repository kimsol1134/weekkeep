import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class WeekkeepAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let environment: AppEnvironment

    override init() {
#if DEBUG
        let processInfo = ProcessInfo.processInfo
        let isAppStoreScreenshot = processInfo.arguments.contains("-ui-app-store-fixtures")
        let isFixture = processInfo.arguments.contains("-ui-fixtures")
            || processInfo.environment["WK_UI_TEST_FIXTURES"] == "1"
        if isAppStoreScreenshot {
            environment = AppEnvironment.appStoreScreenshotFixtures()
        } else {
            environment = isFixture ? AppEnvironment.fixtures() : AppEnvironment.live()
        }
#else
        // Test-only launch arguments must never select a fixture environment
        // in a distribution build.
        environment = AppEnvironment.live()
#endif
        super.init()
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
#if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ui-export-share-artifacts") {
            do {
                let directory = try ShareArtifactFixtureExporter.exportEnglishArtifacts()
                print("WK_SHARE_EXPORT_DIR=\(directory.path)")
            } catch {
                assertionFailure("Share artifact fixture export failed: \(error)")
            }
        }
#endif
        return true
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let link = NotificationDeepLinkParser.parse(
            userInfo: response.notification.request.content.userInfo
        )
        completionHandler()
        guard let link else { return }
        Task { @MainActor [weak self] in
            if let self {
                self.environment.appRouter.route(link, in: self.environment)
            }
        }
    }
}

@main
struct WeekkeepApp: App {
    @UIApplicationDelegateAdaptor(WeekkeepAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appDelegate.environment)
                .weekkeepTheme()
                .preferredColorScheme(.light)
                .onOpenURL { url in
                    let environment = appDelegate.environment
                    if let link = environment.appRouter.parse(url) {
                        environment.appRouter.route(link, in: environment)
                    }
                }
        }
    }
}

#if DEBUG
@MainActor
private enum ShareArtifactFixtureExporter {
    static func exportEnglishArtifacts() throws -> URL {
        let start = ISO8601DateFormatter().date(from: "2026-07-30T00:00:00Z")!
        let photoIDs = SamplePhotoFixtures.assetNames.indices.map { PhotoID("share-fixture-\($0)") }
        let photos = photoIDs.enumerated().map { index, id in
            AlbumPhotoSnapshot(
                id: UUID(),
                assetLocalIdentifier: id,
                capturedAt: start.addingTimeInterval(Double(index) * 86_400),
                position: index,
                source: .initial,
                scoreSnapshot: nil,
                isAvailable: true
            )
        }
        let album = WeeklyAlbumSnapshot(
            id: UUID(),
            weekKey: "2026-W31",
            kind: .regular,
            weekStart: start,
            weekEnd: start.addingTimeInterval(604_800),
            analysisCutoff: start.addingTimeInterval(604_800),
            createdAt: start,
            updatedAt: start,
            coverPhotoID: photos.first?.id,
            photos: photos
        )

        var images: [PhotoID: PhotoImageData] = [:]
        for (index, id) in photoIDs.enumerated() {
            guard let image = UIImage(named: SamplePhotoFixtures.assetName(for: index)),
                  let data = image.pngData() else {
                throw WeeklyAlbumShareRenderError.invalidPhotoData
            }
            images[id] = PhotoImageData(
                data: data,
                pixelWidth: Int(image.size.width * image.scale),
                pixelHeight: Int(image.size.height * image.scale)
            )
        }

        let renderer = WeeklyAlbumShareRenderer(
            locale: Locale(identifier: "en_US"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
            wordmarkImage: UIImage(named: "WeekkeepWordmark")
        )
        let directory = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("ShareArtifactFixtures", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try renderer.render(album: album, images: images, format: .story)
            .write(to: directory.appendingPathComponent("weekkeep-story-en.jpg"), options: .atomic)
        try renderer.render(album: album, images: images, format: .post)
            .write(to: directory.appendingPathComponent("weekkeep-post-en.jpg"), options: .atomic)
        return directory
    }
}
#endif
