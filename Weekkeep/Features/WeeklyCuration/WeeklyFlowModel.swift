import Foundation
import Dispatch
import Observation
import UIKit

enum WeeklyRoute: String, Equatable, Sendable, Identifiable {
    case curation
    case review
    case saveConfirmation

    var id: String { rawValue }
}

enum WeeklySheet: Identifiable, Equatable, Sendable {
    case replacement(index: Int)
    case notificationPrimer
    case paywall

    var id: String {
        switch self {
        case let .replacement(index): "replacement-\(index)"
        case .notificationPrimer: "notification-primer"
        case .paywall: "paywall"
        }
    }
}

enum WeeklyPendingDeepLinkAction: Equatable, Sendable {
    case refreshWeekly
    case presentPlus
}

enum CurationReviewState: Equatable, Sendable {
    case idle
    case ready
    case partialSuccess(skippedAssetCount: Int)

    static func afterAnalysis(skippedAssetCount: Int) -> Self {
        skippedAssetCount > 0 ? .partialSuccess(skippedAssetCount: skippedAssetCount) : .ready
    }

    var isPartialSuccess: Bool {
        if case .partialSuccess = self { return true }
        return false
    }

    var skippedAssetCount: Int? {
        if case let .partialSuccess(count) = self { return count }
        return nil
    }
}

protocol CurationMonotonicClock: Sendable {
    func nowNanoseconds() -> UInt64
}

struct SystemCurationMonotonicClock: CurationMonotonicClock, Sendable {
    func nowNanoseconds() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds
    }
}

@MainActor
@Observable
final class WeeklyFlowModel {
    let environment: AppEnvironment
    let reviewReducer = ReviewInteractionReducer()

    var rootState: WeekRootState = .loading(.permission)
    var route: WeeklyRoute?
    var draft: CurationDraft?
    var progress: CurationProgress?
    var reviewState: CurationReviewState = .idle
    private(set) var eligiblePhotoCountForCuration: Int?
    var reviewPresentation = ReviewPresentationState.initial
    var savedAlbum: WeeklyAlbumSnapshot?
    private(set) var savedAlbumCount: Int? = nil
    var sheet: WeeklySheet?
    var errorMessage: String?
    var isSaving = false
    var replacementShowsOtherDays = false

    @ObservationIgnored private var analysisTask: Task<Void, Never>?
    @ObservationIgnored private var reviewActivity = ReviewActivityTracker()
    @ObservationIgnored private var hasAppeared = false
    @ObservationIgnored private var isRefreshing = false
    @ObservationIgnored private var shouldOfferNotificationPrimerAfterSave = false
    @ObservationIgnored private var postSaveDestination: AppTab?
    @ObservationIgnored private let curationClock: any CurationMonotonicClock
    @ObservationIgnored private var analysisStartNanoseconds: UInt64?

    private var rootStateReducer: WeekRootStateReducer {
        WeekRootStateReducer(freeAlbumLimit: environment.entitlementPolicy.freeAlbumLimit)
    }

    init(environment: AppEnvironment, curationClock: any CurationMonotonicClock = SystemCurationMonotonicClock()) {
        self.environment = environment
        self.curationClock = curationClock
    }

    deinit {
        analysisTask?.cancel()
    }

    func onAppear() async {
        guard !hasAppeared else { return }
        hasAppeared = true
        await refresh()
        if environment.shouldStartWelcomeCuration {
            environment.shouldStartWelcomeCuration = false
            if environment.pendingDeepLink != .plus {
                startCuration()
            }
        }
    }

    static func pendingDeepLinkAction(for link: AppDeepLink?) -> WeeklyPendingDeepLinkAction? {
        switch link {
        case .weeklyCurrent:
            .refreshWeekly
        case .plus:
            .presentPlus
        default:
            nil
        }
    }

    @discardableResult
    func consumePendingDeepLink() async -> WeeklyPendingDeepLinkAction? {
        guard let pendingLink = environment.pendingDeepLink,
              let action = Self.pendingDeepLinkAction(for: pendingLink) else {
            return nil
        }

        environment.pendingDeepLink = nil
        switch action {
        case .refreshWeekly:
            await refresh()
        case .presentPlus:
            sheet = .paywall
        }
        return action
    }

    func refresh() async {
        guard route == nil, !isRefreshing else { return }
        isRefreshing = true
        eligiblePhotoCountForCuration = nil
        defer { isRefreshing = false }

        let permission = await environment.photoLibrary.authorizationStatus()
        let permissionState: LoadState<PhotoAuthorization> = .loaded(permission)
        guard permission.accessScope != nil else {
            rootState = rootStateReducer.reduce(snapshot: WeekRootSnapshot(
                permission: permissionState,
                localState: .pending,
                eligiblePhotoCount: nil,
                creationAccess: nil
            ))
            return
        }

        rootState = .loading(.localState)
        let albums: [WeeklyAlbumSummary]
        do {
            albums = try await environment.albumStore.listAlbums()
        } catch {
            rootState = .recoverableError(.localState)
            return
        }
        savedAlbumCount = albums.count

        let now = Date()
        let welcomeSaved = albums.contains { $0.kind == .welcome }
        if environment.regularCycleStartsAt == nil,
           let welcome = albums.first(where: { $0.kind == .welcome }) {
            environment.regularCycleStartsAt = environment.weekCalculator.regularCycleStart(forWelcomeSavedAt: welcome.createdAt)
        }

        if !welcomeSaved {
            savedAlbum = nil
            let local = LocalWeekState(
                welcomeSaved: false,
                target: nil,
                savedAlbumID: nil,
                savedAlbumCount: albums.count
            )
            let welcomeRange = environment.weekCalculator.welcomeRange(analysisStartedAt: now)
            rootState = .loading(.photos)
            do {
                let descriptors = try await environment.photoLibrary.fetchDescriptors(
                    in: DateInterval(start: welcomeRange.start, end: welcomeRange.end),
                    limit: 500
                )
                let eligibleCount = descriptors.filter(\.isEligible).count
                eligiblePhotoCountForCuration = eligibleCount
                rootState = rootStateReducer.reduce(snapshot: WeekRootSnapshot(
                    permission: permissionState,
                    localState: .loaded(local),
                    eligiblePhotoCount: .loaded(eligibleCount),
                    creationAccess: nil
                ))
            } catch {
                rootState = .recoverableError(.photos)
            }
            return
        }

        let target = environment.weekCalculator.latestEligibleRegular(
            now: now,
            regularCycleStartsAt: environment.regularCycleStartsAt
        )
        let saved = target.flatMap { target in albums.first(where: { $0.weekKey == target.key }) }
        let local = LocalWeekState(
            welcomeSaved: true,
            target: target,
            savedAlbumID: saved?.id,
            savedAlbumCount: albums.count
        )

        guard let target else {
            savedAlbum = nil
            rootState = rootStateReducer.reduce(snapshot: WeekRootSnapshot(
                permission: permissionState,
                localState: .loaded(local),
                eligiblePhotoCount: nil,
                creationAccess: nil
            ))
            return
        }

        if let saved {
            do {
                guard let album = try await environment.albumStore.album(for: saved.weekKey) else {
                    rootState = .recoverableError(.localState)
                    return
                }
                savedAlbum = album
                rootState = rootStateReducer.reduce(snapshot: WeekRootSnapshot(
                    permission: permissionState,
                    localState: .loaded(local),
                    eligiblePhotoCount: nil,
                    creationAccess: nil
                ))
            } catch {
                rootState = .recoverableError(.localState)
            }
            return
        }

        savedAlbum = nil
        rootState = .loading(.photos)
        let eligibleCount: Int
        do {
            let descriptors = try await environment.photoLibrary.fetchDescriptors(
                in: DateInterval(start: target.start, end: target.end),
                limit: 500
            )
            eligibleCount = descriptors.filter(\.isEligible).count
        } catch {
            rootState = .recoverableError(.photos)
            return
        }
        eligiblePhotoCountForCuration = eligibleCount

        let access: LoadState<CreationAccess>? = eligibleCount > 0 && albums.count >= environment.entitlementPolicy.freeAlbumLimit
            ? .loaded((await environment.purchaseClient.entitlementState()).creationAccess)
            : nil
        rootState = rootStateReducer.reduce(snapshot: WeekRootSnapshot(
            permission: permissionState,
            localState: .loaded(local),
            eligiblePhotoCount: .loaded(eligibleCount),
            creationAccess: access
        ))
    }

    func requestPhotosAndStart() async {
        let status = await environment.photoLibrary.requestAuthorization()
        await environment.analyticsClient.capture(.photoPermissionResolved(status: permissionBucket(status)))
        if status.accessScope != nil {
            environment.onboardingCompleted = true
            await refresh()
            startCuration()
        } else {
            await refresh()
        }
    }

    func startCuration() {
        guard analysisTask == nil else { return }
        let now = Date()
        switch rootState {
        case .welcomePending:
            beginCuration(kind: .welcome, target: environment.weekCalculator.welcomeRange(analysisStartedAt: now))
        case .ready:
            guard let regular = environment.weekCalculator.latestEligibleRegular(now: now, regularCycleStartsAt: environment.regularCycleStartsAt) else {
                Task { await refresh() }
                return
            }
            beginCuration(kind: .regular, target: regular)
        case .entitlementLocked:
            guard let regular = environment.weekCalculator.latestEligibleRegular(now: now, regularCycleStartsAt: environment.regularCycleStartsAt) else {
                Task { await refresh() }
                return
            }
            // Keep the exact target while the user is in the purchase flow. The
            // next Monday must not silently replace the week being resumed.
            pinnedTarget = regular
            sheet = .paywall
        default:
            return
        }
    }

    func cancelCuration() {
        analysisTask?.cancel()
        analysisTask = nil
        analysisStartNanoseconds = nil
        progress = nil
        reviewState = .idle
        route = nil
        pinnedTarget = nil
        Task { await refresh() }
    }

    func tapPhoto(at index: Int) {
        guard let draft else { return }
        reviewPresentation = reviewReducer.reduce(reviewPresentation, action: .tapPhoto(index: index), photoCount: draft.selected.count)
    }

    func viewPhoto(at index: Int) {
        guard let draft else { return }
        reviewPresentation = reviewReducer.reduce(reviewPresentation, action: .viewPhoto(index: index), photoCount: draft.selected.count)
    }

    func replacePhoto(at index: Int) {
        guard let draft else { return }
        replacementShowsOtherDays = false
        reviewPresentation = reviewReducer.reduce(reviewPresentation, action: .replacePhoto(index: index), photoCount: draft.selected.count)
    }

    func dismissViewer(at index: Int) {
        reviewPresentation.selectedIndex = index
        reviewPresentation.destination = nil
    }

    func dismissSheet() {
        sheet = nil
        reviewPresentation.destination = nil
        replacementShowsOtherDays = false
    }

    func cancelReview() {
        route = nil
        draft = nil
        reviewState = .idle
        pinnedTarget = nil
        reviewPresentation = .initial
        replacementShowsOtherDays = false
        reviewActivity.reset()
        shouldOfferNotificationPrimerAfterSave = false
        postSaveDestination = nil
        Task { await refresh() }
    }

    func chooseReplacement(_ candidate: PhotoReference, at index: Int) {
        guard let draft else { return }
        do {
            self.draft = try draft.replacing(index: index, with: candidate)
            reviewPresentation.destination = nil
            replacementShowsOtherDays = false
            UISelectionFeedbackGenerator().selectionChanged()
            Task { await environment.analyticsClient.capture(.photoReplaced(replacementIndex: index)) }
        } catch {
            errorMessage = "replace.none"
        }
    }

    func saveDraft() {
        guard let draft, !isSaving else { return }
        isSaving = true
        let reviewDuration = activeReviewDuration()
        Task { [weak self] in
            guard let self else { return }
            do {
                let album = try await environment.albumStore.upsert(draft)
                savedAlbum = album
                if let count = try? await environment.albumStore.savedAlbumCount() {
                    savedAlbumCount = count
                }
                if draft.kind == .welcome {
                    environment.regularCycleStartsAt = environment.weekCalculator.regularCycleStart(forWelcomeSavedAt: album.createdAt)
                }
                let sequence = draft.kind == .welcome ? "not_applicable" : sequenceBucket(for: draft.week.start)
                await environment.analyticsClient.capture(.albumSaved(
                    albumKind: draft.kind,
                    regularSequenceBucket: sequence,
                    selectedCount: draft.selected.count,
                    replacementCount: draft.replacementCount,
                    activeReviewDurationBucket: AnalyticsBucketContract.duration(for: reviewDuration)
                ))
                if draft.kind == .regular {
                    await environment.notificationClient.cancelReminder(for: draft.week.key)
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                route = .saveConfirmation
                let notificationStatus = await environment.notificationClient.authorizationStatus()
                shouldOfferNotificationPrimerAfterSave = NotificationPrimerPolicy.shouldOfferAfterSave(
                    notificationStatus: notificationStatus,
                    primerShown: environment.notificationPrimerShown
                )
                isSaving = false
            } catch {
                errorMessage = "review.saveFailed"
                isSaving = false
            }
        }
    }

    func finishSave(openArchive: Bool = false) {
        guard route == .saveConfirmation else { return }
        if shouldOfferNotificationPrimerAfterSave && !environment.notificationPrimerShown {
            postSaveDestination = openArchive ? .archive : nil
            sheet = .notificationPrimer
            return
        }
        completeSave(openArchive: openArchive)
    }

    private func completeSave(openArchive: Bool) {
        sheet = nil
        route = nil
        draft = nil
        reviewState = .idle
        pinnedTarget = nil
        reviewPresentation = .initial
        replacementShowsOtherDays = false
        reviewActivity.reset()
        shouldOfferNotificationPrimerAfterSave = false
        postSaveDestination = nil
        if openArchive {
            environment.selectedTab = .archive
        }
        Task { await refresh() }
    }

    func acceptNotificationReminder() async {
        environment.notificationPrimerShown = true
        let currentStatus = await environment.notificationClient.authorizationStatus()
        let status: NotificationAuthorization
        if NotificationPrimerPolicy.shouldRequestAuthorization(currentStatus: currentStatus) {
            status = await environment.notificationClient.requestAuthorization()
        } else {
            status = currentStatus
        }
        await environment.analyticsClient.capture(.notificationPermissionResolved(status: status.rawValue))
        if status == .authorized || status == .provisional {
            if let cycle = environment.regularCycleStartsAt {
                try? await environment.notificationClient.scheduleWeeklyReminders(
                    now: Date(),
                    regularCycleStartsAt: cycle,
                    calendar: reminderCalendar()
                )
            }
        }
        sheet = nil
        if route == .saveConfirmation {
            completeSave(openArchive: postSaveDestination == .archive)
        }
    }

    func declineNotificationReminder() {
        environment.notificationPrimerShown = true
        sheet = nil
        if route == .saveConfirmation {
            completeSave(openArchive: postSaveDestination == .archive)
        }
    }

    @discardableResult
    func purchaseDidResolve(_ outcome: PurchaseOutcome) async -> PlusPaywallFeedback? {
        switch outcome {
        case .success:
            switch await confirmPlusEntitlementAndResume() {
            case .resumed:
                return nil
            case .waitingForEntitlement:
                return .pending
            }
        case .cancelled:
            return .cancelled
        case .pending:
            return .pending
        case .failed:
            return .failed
        }
    }

    @discardableResult
    func continueAfterRestore() async -> PlusPaywallContinuationResult {
        await confirmPlusEntitlementAndResume()
    }

    func refreshAfterPaywallDismissal() async {
        _ = await environment.purchaseClient.entitlementState()
        await refresh()
    }

    @discardableResult
    func restoreDidResolve(_ outcome: RestoreOutcome) -> PlusPaywallFeedback {
        switch outcome {
        case .restored:
            return .restored
        case .noPurchase:
            return .noPurchase
        case .failed:
            return .failed
        }
    }

    private func confirmPlusEntitlementAndResume() async -> PlusPaywallContinuationResult {
        // RevenueCat is the source of truth. A restore/purchase callback alone
        // never unlocks the weekly target or dismisses the paywall.
        guard await environment.purchaseClient.entitlementState() == .active else {
            return .waitingForEntitlement
        }

        let target = pinnedTarget
        sheet = nil
        guard route == nil else { return .resumed }

        await refresh()
        if let target {
            beginCuration(kind: .regular, target: target)
        }
        return .resumed
    }

    func activeReviewDuration() -> TimeInterval {
        reviewActivity.elapsed(at: Date())
    }

    func setReviewVisible(_ visible: Bool) {
        reviewActivity.setActive(visible, at: Date())
    }

    func setReviewForegroundActive(_ active: Bool) {
        setReviewVisible(active && route == .review)
    }

    var pinnedTarget: WeekRange?
    var currentReplacementIndex: Int? {
        guard case let .replacement(index) = reviewPresentation.destination else { return nil }
        return index
    }

    var currentPhotoCandidates: [PhotoReference] {
        guard let index = currentReplacementIndex, let draft else { return [] }
        return draft.replacementCandidates(
            for: index,
            timeZoneIdentifier: environment.weekCalculator.timeZoneIdentifier,
            includingOtherDays: replacementShowsOtherDays
        )
    }

    var sameDayReplacementCandidates: [PhotoReference] {
        guard let index = currentReplacementIndex, let draft else { return [] }
        return draft.replacementCandidates(
            for: index,
            timeZoneIdentifier: environment.weekCalculator.timeZoneIdentifier
        )
    }

    var otherDayReplacementCandidates: [PhotoReference] {
        guard let index = currentReplacementIndex, let draft else { return [] }
        return draft.otherDayReplacementCandidates(
            for: index,
            timeZoneIdentifier: environment.weekCalculator.timeZoneIdentifier
        )
    }

    func showOtherDayReplacementCandidates() {
        replacementShowsOtherDays = true
    }
    var candidateCountBucketForCuration: String? {
        eligiblePhotoCountForCuration.map(AnalyticsBucketContract.candidateCount(for:))
    }

    private func beginCuration(kind: AlbumKind, target: WeekRange) {
        guard analysisTask == nil else { return }
        guard let eligiblePhotoCount = eligiblePhotoCountForCuration else {
            Task { await refresh() }
            return
        }
        let candidateCountBucket = AnalyticsBucketContract.candidateCount(for: eligiblePhotoCount)
        pinnedTarget = target
        route = .curation
        draft = nil
        reviewState = .idle
        errorMessage = nil
        progress = CurationProgress(stage: .fetchingAssets, completed: 0, total: 0, skippedCount: 0)
        analysisStartNanoseconds = curationClock.nowNanoseconds()
        Task { await environment.analyticsClient.capture(.curationStarted(albumKind: kind, candidateCountBucket: candidateCountBucket)) }
        analysisTask = Task { [weak self] in
            guard let self else { return }
            do {
                let draft = try await environment.analysisService.makeDraft(
                    kind: kind,
                    week: target,
                    analysisCutoff: target.cutoff,
                    progress: { [weak self] progress in
                        Task { @MainActor [weak self] in self?.progress = progress }
                    }
                )
                try Task.checkCancellation()
                draftDidFinish(draft)
            } catch is CancellationError {
                analysisDidCancel()
            } catch {
                analysisDidFail()
            }
            analysisTask = nil
        }
    }

    private func draftDidFinish(_ draft: CurationDraft) {
        let durationBucket = completedAnalysisDurationBucket()
        self.draft = draft
        self.progress = nil
        self.route = .review
        self.reviewState = .afterAnalysis(skippedAssetCount: draft.skippedAssetCount)
        self.reviewPresentation = .initial
        reviewActivity.reset()
        if let durationBucket {
            Task { await environment.analyticsClient.capture(.curationCompleted(durationBucket: durationBucket, selectedCount: draft.selected.count)) }
        }
    }

    private func analysisDidCancel() {
        analysisStartNanoseconds = nil
        progress = nil
        reviewState = .idle
        route = nil
        pinnedTarget = nil
        Task { await refresh() }
    }

    private func analysisDidFail() {
        analysisStartNanoseconds = nil
        progress = nil
        reviewState = .idle
        errorMessage = "curation.failed"
        route = nil
        Task { await environment.analyticsClient.capture(.curationFailed(errorKind: "analysis")) }
        Task { await refresh() }
    }

    private func permissionBucket(_ status: PhotoAuthorization) -> String {
        switch status {
        case .authorized: "full"
        case .limited: "limited"
        case .denied: "denied"
        case .restricted: "restricted"
        case .notDetermined: "not_determined"
        }
    }

    private func sequenceBucket(for weekStart: Date) -> String {
        guard let cycle = environment.regularCycleStartsAt else { return "unknown" }
        return environment.weekCalculator.regularSequenceBucket(weekStart: weekStart, regularCycleStartsAt: cycle)
    }

    private func completedAnalysisDurationBucket() -> String? {
        guard let startedAt = analysisStartNanoseconds else { return nil }
        analysisStartNanoseconds = nil
        let finishedAt = curationClock.nowNanoseconds()
        let elapsedNanoseconds = finishedAt >= startedAt ? finishedAt - startedAt : 0
        let elapsed = TimeInterval(elapsedNanoseconds) / 1_000_000_000
        return AnalyticsBucketContract.duration(for: elapsed)
    }

    private func reminderCalendar() -> Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: environment.weekCalculator.timeZoneIdentifier) ?? .current
        return calendar
    }
}

private extension LoadState {
    var isLoaded: Bool {
        if case .loaded = self { return true }
        return false
    }
}
