import XCTest
@testable import Weekkeep

final class ReleaseCandidateHardeningTests: XCTestCase {
    func testSettingsPhotoAccessPresentationUsesTruthfulActionsForEveryStatus() {
        let notDetermined = SettingsPhotoAccessPresentation(permission: .notDetermined)
        let authorized = SettingsPhotoAccessPresentation(permission: .authorized)
        let limited = SettingsPhotoAccessPresentation(permission: .limited)
        let denied = SettingsPhotoAccessPresentation(permission: .denied)
        let restricted = SettingsPhotoAccessPresentation(permission: .restricted)

        XCTAssertEqual(notDetermined.action, .requestAuthorization)
        XCTAssertEqual(notDetermined.statusKey, "settings.notDeterminedAccess")
        XCTAssertEqual(notDetermined.actionTitleKey, "settings.requestPhotoAccess")
        XCTAssertEqual(authorized.action, .openSettings)
        XCTAssertEqual(limited.action, .openSettings)
        XCTAssertEqual(denied.action, .openSettings)
        XCTAssertEqual(denied.actionTitleKey, "common.openSettings")
        XCTAssertEqual(restricted.action, .none)
        XCTAssertFalse(restricted.showsAction)
        XCTAssertNil(restricted.actionTitleKey)
        XCTAssertEqual(restricted.explanationKey, "week.restrictedBody")
    }

    func testSettingsNotificationPresentationGatesPermissionUntilAWeekIsSaved() {
        let statuses: [NotificationAuthorization] = [
            .notDetermined,
            .authorized,
            .provisional,
            .denied,
            .ephemeral
        ]

        for status in statuses {
            let presentation = SettingsNotificationPresentation(
                notificationStatus: status,
                savedAlbumCount: 0
            )

            XCTAssertEqual(presentation.action, .none, "Unexpected action for \(status)")
            XCTAssertFalse(presentation.showsAction)
            XCTAssertEqual(presentation.statusKey, "settings.reminderAvailableAfterSave")
            XCTAssertEqual(presentation.explanationKey, "settings.reminderRequiresSavedAlbum")
            XCTAssertNil(presentation.actionTitleKey)
        }

        let checking = SettingsNotificationPresentation(
            notificationStatus: .notDetermined,
            savedAlbumCount: nil
        )
        XCTAssertEqual(checking.action, .none)
        XCTAssertEqual(checking.statusKey, "settings.reminderChecking")
        XCTAssertNil(checking.explanationKey)
        XCTAssertNil(checking.actionTitleKey)
    }

    func testSettingsNotificationPresentationUsesContextualActionsAfterAWeekIsSaved() {
        let request = SettingsNotificationPresentation(
            notificationStatus: .notDetermined,
            savedAlbumCount: 1
        )
        XCTAssertEqual(request.action, .requestAuthorization)
        XCTAssertEqual(request.statusKey, "settings.reminderNotSet")
        XCTAssertEqual(request.actionTitleKey, "settings.enableReminder")

        for status in [NotificationAuthorization.authorized, .provisional, .denied, .ephemeral] {
            let openSettings = SettingsNotificationPresentation(
                notificationStatus: status,
                savedAlbumCount: 2
            )

            XCTAssertEqual(openSettings.action, .openSettings, "Unexpected action for \(status)")
            XCTAssertTrue(openSettings.showsAction)
            XCTAssertEqual(
                openSettings.actionTitleKey,
                "settings.openNotificationSettings"
            )
        }
    }

    func testNotificationPrimerPolicyOnlyOffersAnUnseenNotDeterminedState() {
        for status in [
            NotificationAuthorization.authorized,
            .provisional,
            .denied,
            .ephemeral
        ] {
            XCTAssertFalse(
                NotificationPrimerPolicy.shouldOfferAfterSave(
                    notificationStatus: status,
                    primerShown: false
                )
            )
        }

        XCTAssertTrue(
            NotificationPrimerPolicy.shouldOfferAfterSave(
                notificationStatus: .notDetermined,
                primerShown: false
            )
        )
        XCTAssertFalse(
            NotificationPrimerPolicy.shouldOfferAfterSave(
                notificationStatus: .notDetermined,
                primerShown: true
            )
        )
        XCTAssertFalse(
            NotificationPrimerPolicy.shouldRequestAuthorization(currentStatus: .authorized)
        )
        XCTAssertTrue(
            NotificationPrimerPolicy.shouldRequestAuthorization(currentStatus: .notDetermined)
        )
    }

    @MainActor
    func testSettingsModelDoesNotRequestNotificationsBeforeFirstSavedAlbum() async throws {
        let notificationClient = SettingsNotificationClientSpy(status: .notDetermined)
        let model = SettingsModel(
            environment: makeEnvironment(
                photoLibrary: SettingsPhotoLibrarySpy(status: .notDetermined),
                notificationClient: notificationClient
            )
        )

        await model.load()
        XCTAssertEqual(model.savedAlbumCount, 0)
        XCTAssertEqual(model.notificationPresentation.action, .none)

        model.manageNotifications()
        try await Task.sleep(for: .milliseconds(50))

        let requestCount = await notificationClient.requestCount()
        let scheduleCount = await notificationClient.scheduleCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertEqual(scheduleCount, 0)
    }

    @MainActor
    func testSettingsModelRequestsNotificationsAfterAWeekIsSaved() async throws {
        let notificationClient = SettingsNotificationClientSpy(status: .notDetermined)
        let albumStore = InMemoryAlbumStore(initialAlbums: [savedAlbumSnapshot()])
        let model = SettingsModel(
            environment: makeEnvironment(
                photoLibrary: SettingsPhotoLibrarySpy(status: .notDetermined),
                albumStore: albumStore,
                notificationClient: notificationClient
            )
        )

        await model.load()
        XCTAssertEqual(model.savedAlbumCount, 1)
        XCTAssertEqual(model.notificationPresentation.action, .requestAuthorization)

        model.manageNotifications()
        try await Task.sleep(for: .milliseconds(50))

        let requestCount = await notificationClient.requestCount()
        XCTAssertEqual(requestCount, 1)
    }

    @MainActor
    func testNotificationPrimerDoesNotRequestAuthorizationASecondTime() async {
        let notificationClient = SettingsNotificationClientSpy(status: .authorized)
        let model = WeeklyFlowModel(
            environment: makeEnvironment(
                photoLibrary: SettingsPhotoLibrarySpy(status: .authorized),
                notificationClient: notificationClient
            )
        )

        await model.acceptNotificationReminder()

        let requestCount = await notificationClient.requestCount()
        XCTAssertEqual(requestCount, 0)
    }

    @MainActor
    func testSettingsNotDeterminedActionRequestsPermissionAndRefreshesWithoutUIApplication() async {
        let library = SettingsPhotoLibrarySpy(status: .notDetermined)
        let environment = makeEnvironment(photoLibrary: library)
        let model = SettingsModel(environment: environment)

        await model.refreshPhotoPermission()
        XCTAssertEqual(model.photoAccessPresentation.action, .requestAuthorization)

        await model.requestPhotoAccess()

        let requestCount = await library.requestCount()
        XCTAssertEqual(requestCount, 1)
        XCTAssertEqual(model.photoPermission, .authorized)
        XCTAssertEqual(model.photoAccessPresentation.action, .openSettings)
    }

    func testDeniedPermissionOffersSettingsButRestrictedPermissionDoesNot() {
        let denied = PermissionBlockedPresentation(issue: .denied)
        let restricted = PermissionBlockedPresentation(issue: .restricted)

        XCTAssertTrue(denied.showsSettingsAction)
        XCTAssertFalse(restricted.showsSettingsAction)
        XCTAssertEqual(denied.titleKey, "week.permissionTitle")
        XCTAssertEqual(restricted.titleKey, "week.restrictedTitle")
        XCTAssertEqual(restricted.bodyKey, "week.restrictedBody")
    }

    func testReplacementAvailabilityUsesCloseOnlyForZeroCandidates() {
        let noCandidates = ReplacementCandidatePresentation(sameDayCount: 0, otherDayCount: 0)
        let otherDaysOnly = ReplacementCandidatePresentation(sameDayCount: 0, otherDayCount: 2)
        let bothGroups = ReplacementCandidatePresentation(sameDayCount: 1, otherDayCount: 2)

        XCTAssertTrue(noCandidates.showsCloseOnly)
        XCTAssertFalse(noCandidates.showsOtherDaysAction)
        XCTAssertFalse(otherDaysOnly.showsCloseOnly)
        XCTAssertTrue(otherDaysOnly.showsOtherDaysAction)
        XCTAssertFalse(bothGroups.showsCloseOnly)
        XCTAssertTrue(bothGroups.showsOtherDaysAction)
    }

    func testReviewDateFormattingUsesInjectedTimeZoneAtCalendarBoundary() {
        let formatter = ISO8601DateFormatter()
        let boundary = try! XCTUnwrap(formatter.date(from: "2026-01-01T00:30:00Z"))
        let utc = WeeklyReviewDateFormatting.candidateLabel(
            boundary,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZoneIdentifier: "UTC"
        )
        let losAngeles = WeeklyReviewDateFormatting.candidateLabel(
            boundary,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZoneIdentifier: "America/Los_Angeles"
        )

        XCTAssertNotEqual(utc, losAngeles)
        XCTAssertTrue(utc.contains("Jan 1"))
        XCTAssertTrue(losAngeles.contains("Dec 31"))

        let weekEnd = boundary.addingTimeInterval(7 * 24 * 60 * 60)
        let utcRange = WeekkeepLocalization.dateRange(
            start: boundary,
            end: weekEnd,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(identifier: "UTC")!
        )
        let losAngelesRange = WeekkeepLocalization.dateRange(
            start: boundary,
            end: weekEnd,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: TimeZone(identifier: "America/Los_Angeles")!
        )
        XCTAssertNotEqual(utcRange, losAngelesRange)
    }

    func testPhotoRequestProgressIsMonotonicBoundedAndResettable() {
        var aggregator = PhotoRequestProgressAggregator(total: 3)
        var snapshots = [aggregator.progress]

        XCTAssertEqual(
            PhotoRequestProgress(completed: 99, total: 3),
            PhotoRequestProgress(completed: 3, total: 3)
        )

        aggregator.completeRequest()
        snapshots.append(aggregator.progress)
        aggregator.completeRequest()
        snapshots.append(aggregator.progress)
        aggregator.completeRemainingRequests()
        snapshots.append(aggregator.progress)

        XCTAssertEqual(snapshots.map(\.completed), [0, 1, 2, 3])
        XCTAssertEqual(snapshots.map(\.total), [3, 3, 3, 3])
        XCTAssertEqual(snapshots.last?.fraction, 1)
        for pair in zip(snapshots, snapshots.dropFirst()) {
            XCTAssertGreaterThanOrEqual(pair.1.completed, pair.0.completed)
            XCTAssertGreaterThanOrEqual(pair.1.fraction, pair.0.fraction)
            XCTAssertGreaterThanOrEqual(pair.1.fraction, 0)
            XCTAssertLessThanOrEqual(pair.1.fraction, 1)
        }

        aggregator.cancel()
        XCTAssertEqual(aggregator.progress, PhotoRequestProgress(completed: 0, total: 0))
        aggregator.reset(total: 2)
        XCTAssertEqual(aggregator.progress, PhotoRequestProgress(completed: 0, total: 2))
    }

    @MainActor
    func testPaywallOutcomeMappingKeepsFeedbackInsidePaywall() async {
        let model = WeeklyFlowModel(environment: AppEnvironment.fixtures())

        let cancelled = await model.purchaseDidResolve(.cancelled)
        let pending = await model.purchaseDidResolve(.pending)
        let failed = await model.purchaseDidResolve(.failed)
        XCTAssertEqual(cancelled, .cancelled)
        XCTAssertEqual(pending, .pending)
        XCTAssertEqual(failed, .failed)
        XCTAssertEqual(model.restoreDidResolve(.restored), .restored)
        XCTAssertEqual(model.restoreDidResolve(.noPurchase), .noPurchase)
        XCTAssertEqual(model.restoreDidResolve(.failed), .failed)
        XCTAssertEqual(PlusPaywallFeedback.unavailable.localizationKey, "paywall.unavailable")
    }

    func testRestoredPaywallStateShowsContinuationInsteadOfPurchaseAction() {
        let restored = PlusPaywallRestoreState.restored

        XCTAssertTrue(restored.suppressesPurchaseAction)
        XCTAssertEqual(restored.continuationTitleKey, "paywall.continue")
        XCTAssertNil(PlusPaywallRestoreState.checkingEntitlement.continuationTitleKey)
    }

    @MainActor
    func testRestoreContinuationResumesPinnedTargetOnlyAfterActiveEntitlement() async {
        let environment = AppEnvironment.fixtures(purchaseState: .active)
        let model = WeeklyFlowModel(environment: environment)
        let target = environment.weekCalculator.regularRange(startingAt: Date(timeIntervalSince1970: 0))
        model.pinnedTarget = target
        model.sheet = .paywall

        let result = await model.continueAfterRestore()

        XCTAssertEqual(result, .resumed)
        XCTAssertNil(model.sheet)
        XCTAssertEqual(model.route, .curation)
        XCTAssertEqual(model.pinnedTarget, target)
        model.cancelCuration()
    }

    @MainActor
    func testRestoreContinuationDoesNotUnlockInactiveOrUnknownEntitlement() async {
        for state in [EntitlementState.inactive, .unknown] {
            let environment = AppEnvironment.fixtures(purchaseState: state)
            let model = WeeklyFlowModel(environment: environment)
            model.rootState = .entitlementLocked
            model.sheet = .paywall

            let result = await model.continueAfterRestore()

            XCTAssertEqual(result, .waitingForEntitlement)
            XCTAssertEqual(model.sheet, .paywall)
            XCTAssertEqual(model.rootState, .entitlementLocked)
        }
    }

    @MainActor
    func testPaywallDismissalRefreshesWeeklyStateFromSourceOfTruth() async {
        let environment = AppEnvironment.fixtures(purchaseState: .active)
        let model = WeeklyFlowModel(environment: environment)
        model.rootState = .entitlementLocked
        model.sheet = .paywall

        await model.refreshAfterPaywallDismissal()

        XCTAssertNotEqual(model.rootState, .entitlementLocked)
    }

    @MainActor
    func testSettingsReloadReflectsConfirmedPlusAfterPaywallClose() async {
        let settings = SettingsModel(environment: AppEnvironment.fixtures(purchaseState: .active))

        await settings.load()

        XCTAssertEqual(settings.entitlement, .active)
    }

    func testEveryPaywallOutcomeHasAnInPaywallBannerContract() {
        let outcomes: [PlusPaywallFeedback] = [
            .unavailable,
            .cancelled,
            .pending,
            .failed,
            .restored,
            .noPurchase
        ]

        XCTAssertEqual(
            outcomes.map(\.localizationKey),
            [
                "paywall.unavailable",
                "paywall.cancelled",
                "paywall.pending",
                "paywall.failed",
                "paywall.restored",
                "paywall.noPurchase"
            ]
        )
        XCTAssertEqual(
            outcomes.map(\.accessibilityIdentifier),
            [
                "SHEET-PAY-01-Outcome-unavailable",
                "SHEET-PAY-01-Outcome-cancelled",
                "SHEET-PAY-01-Outcome-pending",
                "SHEET-PAY-01-Outcome-failed",
                "SHEET-PAY-01-Outcome-restored",
                "SHEET-PAY-01-Outcome-noPurchase"
            ]
        )
    }

    @MainActor
    func testPaywallCallerSuppliesActualSavedAlbumCountToAnalytics() {
        let model = WeeklyFlowModel(environment: AppEnvironment.fixtures())
        let paywall = PlusPaywallView(model: model, savedAlbumCount: 1)

        XCTAssertEqual(paywall.savedAlbumCount, 1)
        let event = AnalyticsEvent.paywallViewed(freeAlbumCount: paywall.savedAlbumCount!)
        XCTAssertEqual(event.properties["free_album_count"], "1")
    }

    @MainActor
    func testSettingsPaywallCallerUsesLoadedAlbumCount() async {
        let environment = AppEnvironment.fixtures()
        let settings = SettingsModel(environment: environment)

        await settings.load()

        let expectedCount = try! await environment.albumStore.savedAlbumCount()
        let paywall = PlusPaywallView(
            model: WeeklyFlowModel(environment: environment),
            savedAlbumCount: settings.savedAlbumCount
        )

        XCTAssertEqual(settings.savedAlbumCount, expectedCount)
        XCTAssertEqual(paywall.savedAlbumCount, expectedCount)
        XCTAssertEqual(
            AnalyticsEvent.paywallViewed(freeAlbumCount: expectedCount).properties["free_album_count"],
            String(expectedCount)
        )
    }

    @MainActor
    private func makeEnvironment(
        photoLibrary: any PhotoLibraryClient,
        albumStore: (any AlbumStore)? = nil,
        notificationClient: (any NotificationClient)? = nil
    ) -> AppEnvironment {
        AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: FixturePhotoAnalysisService(photoLibrary: photoLibrary),
            albumStore: albumStore ?? InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: notificationClient ?? FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: UserDefaults(suiteName: "weekkeep.hardening.\(UUID().uuidString)")!,
            isFixture: true
        )
    }

    private func savedAlbumSnapshot() -> WeeklyAlbumSnapshot {
        let now = Date(timeIntervalSince1970: 1_754_524_800)
        return WeeklyAlbumSnapshot(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            weekKey: "saved-week-fixture",
            kind: .welcome,
            weekStart: now,
            weekEnd: now.addingTimeInterval(6 * 24 * 60 * 60),
            analysisCutoff: now,
            createdAt: now,
            updatedAt: now,
            coverPhotoID: nil,
            photos: []
        )
    }
}

private actor SettingsPhotoLibrarySpy: PhotoLibraryClient {
    private var status: PhotoAuthorization
    private var requests = 0

    init(status: PhotoAuthorization) {
        self.status = status
    }

    func authorizationStatus() async -> PhotoAuthorization { status }

    func requestAuthorization() async -> PhotoAuthorization {
        requests += 1
        status = .authorized
        return status
    }

    func requestCount() -> Int { requests }

    func fetchDescriptors(in range: DateInterval, limit: Int) async throws -> [PhotoDescriptor] { [] }

    func analysisImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        PhotoImageData(data: Data(), pixelWidth: 1, pixelHeight: 1)
    }

    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        PhotoImageData(data: Data(), pixelWidth: 1, pixelHeight: 1)
    }

    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID> { [] }
}

private actor SettingsNotificationClientSpy: NotificationClient {
    private var status: NotificationAuthorization
    private var requests = 0
    private var schedules = 0

    init(status: NotificationAuthorization) {
        self.status = status
    }

    func authorizationStatus() async -> NotificationAuthorization { status }

    func requestAuthorization() async -> NotificationAuthorization {
        requests += 1
        status = .authorized
        return status
    }

    func scheduleWeeklyReminders(now: Date, regularCycleStartsAt: Date, calendar: Calendar) async throws {
        _ = now
        _ = regularCycleStartsAt
        _ = calendar
        schedules += 1
    }

    func cancelReminder(for weekKey: String) async {
        _ = weekKey
    }

    func requestCount() -> Int { requests }

    func scheduleCount() -> Int { schedules }
}
