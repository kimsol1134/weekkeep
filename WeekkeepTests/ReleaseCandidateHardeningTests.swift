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

    func testSettingsSemanticRolesMatchTruthfulStateMeaning() {
        XCTAssertEqual(SettingsSemanticRole.photoAccess(.authorized), .success)
        XCTAssertEqual(SettingsSemanticRole.photoAccess(.limited), .attention)
        XCTAssertEqual(SettingsSemanticRole.photoAccess(.notDetermined), .attention)
        XCTAssertEqual(SettingsSemanticRole.photoAccess(.restricted), .attention)
        XCTAssertEqual(SettingsSemanticRole.photoAccess(.denied), .error)

        XCTAssertEqual(
            SettingsSemanticRole.notification(.authorized, savedAlbumCount: 1),
            .success
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.provisional, savedAlbumCount: 1),
            .attention
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.denied, savedAlbumCount: 1),
            .error
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.authorized, savedAlbumCount: 0),
            .attention
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.authorized, savedAlbumCount: nil),
            .attention
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.denied, savedAlbumCount: 0),
            .error
        )
        XCTAssertEqual(
            SettingsSemanticRole.notification(.denied, savedAlbumCount: nil),
            .error
        )

        XCTAssertEqual(SettingsSemanticRole.entitlement(.active), .success)
        XCTAssertEqual(SettingsSemanticRole.entitlement(.inactive), .neutral)
        XCTAssertEqual(SettingsSemanticRole.entitlement(.unknown), .attention)
    }

    func testSettingsVisualHierarchyUsesSemanticRolesWithoutWeakTitleStyling() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/Features/Settings/SettingsViews.swift"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("SettingsSectionHeader"))
        XCTAssertTrue(source.contains("SettingsSemanticRole"))
        XCTAssertTrue(source.contains("foregroundStyle(WeekkeepColors.primaryText)"))
        XCTAssertTrue(source.contains("foregroundStyle(WeekkeepColors.secondaryAction)"))
        XCTAssertTrue(source.contains("case .status:"))
        XCTAssertTrue(source.contains("safeAreaInset(edge: .bottom"))
        XCTAssertFalse(source.contains("SettingsInformationalRow"))

        let normalizedSource = source.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        XCTAssertTrue(
            normalizedSource.contains(
                "SettingsExplanationRow( title: LocalizedStringKey(explanationKey), role: .photoAccess(model.photoPermission) )"
            )
        )
        XCTAssertTrue(
            normalizedSource.contains(
                "SettingsExplanationRow( title: LocalizedStringKey(explanationKey), role: .notification( model.notificationStatus, savedAlbumCount: model.savedAlbumCount ) )"
            )
        )
        XCTAssertFalse(normalizedSource.contains("SettingsExplanationRow( title: LocalizedStringKey(explanationKey), role: .attention )"))
        XCTAssertFalse(source.contains("case action"))
        XCTAssertFalse(source.contains("case .action"))
    }

    func testSettingsSourceKeepsOnlyActionableRowsAndCompactSupport() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/Features/Settings/SettingsViews.swift"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("action: photoAccessAction"))
        XCTAssertTrue(source.contains("action: notificationAction"))
        XCTAssertFalse(source.contains("SCR-SET-01-NotificationAction"))
        XCTAssertFalse(source.contains("settings.storage"))
        XCTAssertFalse(source.contains("settings.data"))
        XCTAssertFalse(source.contains("about.licenses"))
        XCTAssertFalse(source.contains("OpenSourceLicensesView"))
        XCTAssertFalse(source.contains("LicenseNotice"))
        XCTAssertFalse(source.contains("PrivacyView"))
        XCTAssertFalse(source.contains("PrivacyFact"))
        XCTAssertTrue(source.contains("SCR-SET-01-SupportSection"))
        XCTAssertTrue(source.contains("List {"))
        XCTAssertTrue(source.contains("AboutLinkRow(title: \"about.help\""))
        XCTAssertTrue(source.contains("AboutLinkRow(title: \"about.contact\""))
        XCTAssertTrue(source.contains("AboutLinkRow(title: \"about.terms\""))
        XCTAssertTrue(source.contains("AboutLinkRow(title: \"about.privacy\""))
        XCTAssertTrue(source.contains("settings.restore"))
        XCTAssertFalse(source.contains("settings.learnPlus"))
        XCTAssertTrue(source.contains("guard model.entitlement == .inactive"))
        XCTAssertTrue(source.contains("if model.entitlement != .active"))

        let restoreRowCount = source.components(separatedBy: "SettingsActionRow(").count - 1
        XCTAssertEqual(restoreRowCount, 1, "Only Restore purchase may remain a separate SettingsActionRow")
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

    func testWaitingStateUsesSavedMemoryActionsWithoutASecondContentRail() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/Features/WeeklyCuration/WeeklyViews.swift"
            ),
            encoding: .utf8
        )
        let waitingStart = try XCTUnwrap(source.range(of: "private struct WaitingStateView"))
        let savedStart = try XCTUnwrap(source.range(of: "private struct SavedStateView"))
        let waitingSource = String(source[waitingStart.lowerBound..<savedStart.lowerBound])

        XCTAssertFalse(waitingSource.contains("SevenStitchRail"))
        XCTAssertTrue(waitingSource.contains("WaitingMemoryCard"))
        XCTAssertTrue(waitingSource.contains("PhotoThumbnailView"))
        XCTAssertTrue(waitingSource.contains("week.waitingNextDate"))
        XCTAssertTrue(waitingSource.contains("week.waitingViewAlbum"))
        XCTAssertTrue(waitingSource.contains("week.waitingShareAlbum"))
        XCTAssertTrue(waitingSource.contains("WeeklyAlbumShareView"))
        XCTAssertTrue(waitingSource.contains(".sheet(item: $destination)"))
        XCTAssertTrue(waitingSource.contains(".disabled(model.waitingAlbum == nil || model.waitingAlbum?.isMissingAllPhotos == true)"))
    }

    func testNotificationPrimerUsesTheExactNextDateCue() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/Features/WeeklyCuration/NotificationPrimerView.swift"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("notification.nextDate"))
        XCTAssertTrue(source.contains("model.nextEligibleDate"))
        XCTAssertTrue(source.contains("notification.schedule"))
        XCTAssertFalse(source.localizedCaseInsensitiveContains("background analysis"))
    }

    @MainActor
    func testWaitingStateLoadsLatestAlbumAndComputesExactNextEligibleDate() async {
        let environment = makeEnvironment(
            photoLibrary: SettingsPhotoLibrarySpy(status: .authorized),
            albumStore: InMemoryAlbumStore(initialAlbums: [savedAlbumSnapshot()])
        )
        let cycle = Date().addingTimeInterval(3 * 24 * 60 * 60)
        environment.regularCycleStartsAt = cycle
        let model = WeeklyFlowModel(environment: environment)

        await model.refresh()

        XCTAssertEqual(model.rootState, .preRegularWaiting)
        XCTAssertEqual(model.waitingAlbum?.weekKey, "saved-week-fixture")
        XCTAssertEqual(
            model.nextEligibleDate,
            environment.weekCalculator.regularRange(startingAt: cycle).eligibleFrom
        )
        XCTAssertTrue(model.waitingAlbum?.isMissingAllPhotos == true)
    }

    func testFirstUseCopyAndPhotoPurposeStringsExplainTheCompletedWeekFallback() throws {
        XCTAssertEqual(
            WeekkeepLocalization.string("onboarding.primary", locale: Locale(identifier: "en_US")),
            "Choose your first week"
        )
        XCTAssertEqual(
            WeekkeepLocalization.string("onboarding.primary", locale: Locale(identifier: "ko_KR")),
            "첫 주 추억 고르기"
        )
        XCTAssertTrue(
            WeekkeepLocalization.string("week.welcomeFallbackBody", locale: Locale(identifier: "en_US"))
                .contains("most recent 7 days")
        )
        XCTAssertTrue(
            WeekkeepLocalization.string("week.welcomeFallbackBody", locale: Locale(identifier: "ko_KR"))
                .contains("최근 7일")
        )

        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let purposeFiles = [
            "Weekkeep/Resources/Info.plist",
            "Weekkeep/Resources/en.lproj/InfoPlist.strings",
            "Weekkeep/Resources/ko.lproj/InfoPlist.strings",
            "project.yml"
        ]
        for path in purposeFiles {
            let contents = try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
            XCTAssertTrue(contents.contains("most recently completed") || contents.contains("최근 완료된"), path)
            XCTAssertTrue(contents.contains("most recent 7 days") || contents.contains("최근 7일"), path)
        }
    }

    func testReleaseMetadataUsesWarmFirstWeekCopyWithoutCurationJargon() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let copyFiles = [
            "release/app-store-metadata.json",
            "docs/10-APP-STORE-METADATA.md"
        ]

        for path in copyFiles {
            let contents = try String(
                contentsOf: repositoryRoot.appendingPathComponent(path),
                encoding: .utf8
            )
            XCTAssertFalse(contents.localizedCaseInsensitiveContains("eligible"), path)
            XCTAssertFalse(contents.contains("적격"), path)
            XCTAssertTrue(contents.contains("most recently completed local Monday–Sunday week"), path)
            XCTAssertTrue(contents.contains("no photos Weekkeep can use"), path)
            XCTAssertTrue(contents.contains("most recent seven days"), path)
            XCTAssertTrue(contents.contains("가장 최근 완료된 월요일부터 일요일까지의 한 주"), path)
            XCTAssertTrue(contents.contains("Weekkeep이 남길 수 있는 사진이 없을 때만 최근 7일"), path)
        }
    }

    func testWeeklyReminderScheduleStaysMondayAt2030WithoutDuplicateTargets() {
        let timeZone = TimeZone(identifier: "Asia/Seoul")!
        let calculator = WeekRangeCalculator(timeZone: timeZone)
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = timeZone
        let now = ISO8601DateFormatter().date(from: "2026-08-05T12:00:00+09:00")!
        let cycle = ISO8601DateFormatter().date(from: "2026-08-03T00:00:00+09:00")!

        let requests = WeeklyReminderSchedule.requests(
            now: now,
            regularCycleStartsAt: cycle,
            calendar: calendar,
            calculator: calculator
        )

        XCTAssertFalse(requests.isEmpty)
        XCTAssertEqual(Set(requests.map(\.targetWeekKey)).count, requests.count)
        for request in requests {
            XCTAssertEqual(calendar.component(.weekday, from: request.reminderDate), 2)
            XCTAssertEqual(calendar.component(.hour, from: request.reminderDate), 20)
            XCTAssertEqual(calendar.component(.minute, from: request.reminderDate), 30)
        }
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
