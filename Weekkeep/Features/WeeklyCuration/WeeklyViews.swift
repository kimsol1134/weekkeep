import SwiftUI

struct WeeklyTabView: View {
    let environment: AppEnvironment
    @State private var model: WeeklyFlowModel
    @Environment(\.scenePhase) private var scenePhase

    init(environment: AppEnvironment) {
        self.environment = environment
        _model = State(initialValue: WeeklyFlowModel(environment: environment))
    }

    var body: some View {
        ZStack {
            ThisWeekView(model: model)
                .accessibilityHidden(model.route != nil)

            if let route = model.route {
                WeeklyFlowRouteContainer(route: route, model: model)
                    .id(route.id)
                    .zIndex(1)
            }
        }
        .weekkeepScreenBackground()
        .task {
            await model.onAppear()
            await model.consumePendingDeepLink()
        }
        .onChange(of: scenePhase) { _, phase in
            model.setReviewForegroundActive(phase == .active)
            guard phase == .active else { return }
            Task { await model.refresh() }
        }
        .toolbar(model.route == nil ? .visible : .hidden, for: .tabBar)
        .onChange(of: environment.pendingDeepLink) { _, link in
            guard link != nil else { return }
            Task { await model.consumePendingDeepLink() }
        }
        .sheet(item: sheetBinding) { sheet in
            switch sheet {
            case .notificationPrimer:
                NotificationPrimerView(model: model)
                    .presentationDetents([.medium])
            case .replacement:
                EmptyView()
            case .paywall:
                EmptyView()
            }
        }
        .fullScreenCover(item: paywallBinding) { _ in
            PlusPaywallView(model: model, savedAlbumCount: model.savedAlbumCount)
        }
        .alert("week.errorTitle", isPresented: errorBinding) {
            Button("common.done", role: .cancel) { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage.map { LocalizedStringKey($0) } ?? "")
        }
    }

    private var sheetBinding: Binding<WeeklySheet?> {
        Binding(
            get: {
                guard let sheet = model.sheet else { return nil }
                if case .notificationPrimer = sheet { return sheet }
                return nil
            },
            set: { model.sheet = $0 }
        )
    }

    private var paywallBinding: Binding<WeeklySheet?> {
        Binding(
            get: {
                guard let sheet = model.sheet else { return nil }
                if case .paywall = sheet { return sheet }
                return nil
            },
            set: { model.sheet = $0 }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { model.errorMessage != nil && model.route != .review },
            set: { if !$0 { model.errorMessage = nil } }
        )
    }
}

private struct WeeklyFlowRouteContainer: View {
    let route: WeeklyRoute
    let model: WeeklyFlowModel

    var body: some View {
        ZStack {
            switch route {
            case .curation:
                CurationProgressView(model: model)
            case .review:
                WeeklyReviewView(model: model)
            case .saveConfirmation:
                SaveConfirmationView(model: model)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WeekkeepColors.primaryBackground)
    }
}

struct ThisWeekView: View {
    let model: WeeklyFlowModel

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                    HStack {
                        WeekkeepWordmark()
                        Spacer()
                        SevenStitchRail(tone: .coral)
                            .frame(width: 118)
                    }
                    .padding(.top, WeekkeepSpacing.four)

                    switch model.rootState {
                    case let .loading(stage):
                        RootLoadingView(stage: stage)
                    case let .permissionBlocked(issue):
                        PermissionBlockedView(issue: issue, model: model)
                    case .recoverableError:
                        RootErrorView { Task { await model.refresh() } }
                    case .welcomePending:
                        ReadyStateView(model: model, isWelcome: true, photoCount: nil)
                    case .preRegularWaiting:
                        WaitingStateView()
                    case .saved:
                        SavedStateView(model: model)
                    case let .noEligiblePhotos(scope):
                        NoPhotosStateView(scope: scope, model: model)
                    case .entitlementLocked:
                        LockedStateView(model: model)
                    case let .ready(scope, photoCount):
                        ReadyStateView(model: model, isWelcome: false, photoCount: photoCount, scope: scope)
                    }
                }
                .padding(.horizontal, screenEdge)
                .padding(.bottom, WeekkeepSpacing.six)
            }
            .scrollIndicators(.hidden)
        }
        .weekkeepScreenBackground()
    }
}

private struct RootLoadingView: View {
    let stage: ResolutionStage

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            ProgressView()
                .tint(WeekkeepColors.primaryAction)
            Text(stage == .permission ? "week.permissionTitle" : "week.readyTitle")
                .font(.weekkeepTitle2)
            Text("week.latest")
                .font(.weekkeepBody)
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct ReadyStateView: View {
    let model: WeeklyFlowModel
    let isWelcome: Bool
    let photoCount: Int?
    var scope: PhotoAccessScope = .full

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            Text(isWelcome ? "week.welcomeTitle" : "week.readyTitle")
                .font(.weekkeepTitle)
                .fixedSize(horizontal: false, vertical: true)
            Text(isWelcome ? "week.readyBody" : "week.readyBody")
                .font(.weekkeepBody)
            ReadyPhotoStack()
            if let photoCount {
                Text(WeekkeepLocalization.string("week.photoCount", photoCount))
                    .font(.weekkeepCallout)
                    .foregroundStyle(WeekkeepColors.secondaryText)
            }
            if scope == .limited { LimitedAccessNotice() }
            PrivacyBadge(title: "week.privacy")
            WeekkeepPrimaryButton(title: "week.makeDraft") { model.startCuration() }
                .accessibilityIdentifier("SCR-WK-01-Start")
        }
        .padding(.top, WeekkeepSpacing.six)
    }
}

private struct ReadyPhotoStack: View {
    var body: some View {
        FixturePhotoStory(style: .compact)
    }
}

private struct LimitedAccessNotice: View {
    var body: some View {
        Label("week.limited", systemImage: "photo.on.rectangle.angled")
            .font(.weekkeepCallout)
            .foregroundStyle(WeekkeepColors.secondaryText)
    }
}

private struct PermissionBlockedView: View {
    let issue: PhotoPermissionIssue
    let model: WeeklyFlowModel

    var body: some View {
        let presentation = PermissionBlockedPresentation(issue: issue)

        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            Image(systemName: presentation.iconName)
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(WeekkeepColors.success)
            Text(LocalizedStringKey(presentation.titleKey))
                .font(.weekkeepTitle2)
            Text(LocalizedStringKey(presentation.bodyKey))
                .font(.weekkeepBody)
                .accessibilityIdentifier(
                    presentation.showsSettingsAction
                        ? "SCR-WK-01-PermissionBody"
                        : "SCR-WK-01-RestrictedPolicy"
                )
            if presentation.showsSettingsAction {
                WeekkeepPrimaryButton(title: "common.openSettings") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                .accessibilityIdentifier("SCR-WK-01-OpenSettings")
            }
            Button("privacy.title") { model.environment.selectedTab = .settings }
                .font(.weekkeepCallout)
                .foregroundStyle(WeekkeepColors.secondaryAction)
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct RootErrorView: View {
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            Text("week.errorTitle")
                .font(.weekkeepTitle2)
            Text("curation.failed")
                .font(.weekkeepBody)
            WeekkeepPrimaryButton(title: "common.retry", action: retry)
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct WaitingStateView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            SevenStitchRail(filledCount: 0, tone: .coral)
            Text("week.waitingTitle")
                .font(.weekkeepTitle2)
            Text("week.waitingBody")
                .font(.weekkeepBody)
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct SavedStateView: View {
    let model: WeeklyFlowModel

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            SevenStitchRail(filledCount: model.savedAlbum?.photos.count ?? 0, tone: .sage)
            Text("week.savedTitle")
                .font(.weekkeepTitle2)
            Text("week.savedBody")
                .font(.weekkeepBody)
            if let album = model.savedAlbum {
                Text(WeekkeepLocalization.string("detail.savedOnDevice", album.photos.count))
                    .font(.weekkeepCallout)
                    .foregroundStyle(WeekkeepColors.secondaryText)
            }
            WeekkeepPrimaryButton(title: "week.viewRecord") {
                if let weekKey = model.savedAlbum?.weekKey {
                    model.environment.pendingDeepLink = .album(weekKey: weekKey)
                }
                model.environment.selectedTab = .archive
            }
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct NoPhotosStateView: View {
    let scope: PhotoAccessScope
    let model: WeeklyFlowModel

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            Text("week.noPhotosTitle")
                .font(.weekkeepTitle2)
                .accessibilityIdentifier("SCR-WK-01-NoPhotosTitle")
            Text("week.noPhotosBody")
                .font(.weekkeepBody)
            if scope == .limited {
                WeekkeepSecondaryButton(title: "week.managePhotos") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            } else {
                WeekkeepSecondaryButton(title: "common.retry") { Task { await model.refresh() } }
            }
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

private struct LockedStateView: View {
    let model: WeeklyFlowModel

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            SevenStitchRail(tone: .sage)
            Text("week.lockedTitle")
                .font(.weekkeepTitle2)
            Text("week.lockedBody")
                .font(.weekkeepBody)
            WeekkeepPrimaryButton(title: "week.plus") { model.startCuration() }
            WeekkeepSecondaryButton(title: "week.viewWeeks") { model.environment.selectedTab = .archive }
        }
        .padding(.top, WeekkeepSpacing.twelve)
    }
}

struct CurationProgressView: View {
    let model: WeeklyFlowModel

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

            VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                HStack {
                    Button(action: model.cancelCuration) {
                        Image(systemName: "chevron.left")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(Text("common.cancel"))
                    Spacer()
                    SevenStitchRail(filledCount: filledCount, tone: .progress)
                }
                .foregroundStyle(WeekkeepColors.primaryText)

                Text("curation.title")
                    .font(.weekkeepTitle)
                    .padding(.top, WeekkeepSpacing.twelve)
                    .accessibilityIdentifier("SCR-WK-02-CurationProgress")
                Text("curation.body")
                    .font(.weekkeepBody)
                ProgressCard(progress: model.progress)
                PrivacyBadge(title: "curation.privacy")
                Spacer()
                WeekkeepSecondaryButton(title: "curation.cancel", action: model.cancelCuration)
            }
            .padding(.horizontal, screenEdge)
            .padding(.vertical, WeekkeepSpacing.four)
        }
        .weekkeepScreenBackground()
    }

    private var filledCount: Int {
        guard let progress = model.progress, progress.overallTotal > 0 else { return 0 }
        return min(7, Int((Double(progress.overallCompleted) / Double(progress.overallTotal) * 7).rounded(.down)))
    }
}

private struct ProgressCard: View {
    let progress: CurationProgress?

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.three) {
            Text(stageKey)
                .font(.weekkeepHeadline)
            if let progress, progress.overallTotal > 0 {
                ProgressView(value: Double(progress.overallCompleted), total: Double(progress.overallTotal))
                    .tint(WeekkeepColors.memoryAccent)
                Text(WeekkeepLocalization.progress("review.bodyCount", completed: progress.overallCompleted, total: progress.overallTotal))
                    .font(.weekkeepCaption)
                    .foregroundStyle(WeekkeepColors.secondaryText)
            } else {
                ProgressView().tint(WeekkeepColors.memoryAccent)
            }
        }
        .padding(WeekkeepSpacing.six)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.large))
        .overlay { RoundedRectangle(cornerRadius: WeekkeepRadii.large).stroke(WeekkeepColors.subtleBorder, lineWidth: 1) }
        .accessibilityElement(children: .combine)
    }

    private var stageKey: LocalizedStringKey {
        switch progress?.stage {
        case .fetchingAssets: "curation.fetching"
        case .prefiltering: "curation.prefiltering"
        case .downloadingFromICloud: "curation.downloading"
        case .analyzing: "curation.analyzing"
        case .deduplicating: "curation.deduplicating"
        case .ranking, .none: "curation.ranking"
        }
    }
}
