import SwiftUI

struct PlusPaywallView: View {
    let model: WeeklyFlowModel
    let savedAlbumCount: Int?
    @State private var offering: PlusOffering?
    @State private var isLoading = true
    @State private var isWorking = false
    @State private var feedback: PlusPaywallFeedback?
    @State private var restoreState: PlusPaywallRestoreState = .idle
    @State private var hasCapturedView = false
    @Environment(\.dismiss) private var dismiss

    init(model: WeeklyFlowModel, savedAlbumCount: Int? = nil) {
        self.model = model
        if let savedAlbumCount {
            self.savedAlbumCount = savedAlbumCount
        } else {
            self.savedAlbumCount = model.savedAlbumCount
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

            ScrollView {
            VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                HStack {
                    Spacer()
                    Button {
                        closePaywall()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                            .background(WeekkeepColors.linen.opacity(0.55), in: Circle())
                    }
                    .accessibilityLabel(Text("common.close"))
                }
                Text("paywall.title")
                    .font(.weekkeepDisplay)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityIdentifier("SHEET-PAY-01-Title")
                FixturePhotoStory(style: .compact)
                    .accessibilityIdentifier("SHEET-PAY-01-PhotoStory")
                if let savedAlbumCount {
                    Text(WeekkeepLocalization.string("paywall.overlineCount", savedAlbumCount))
                        .font(.weekkeepBody)
                        .foregroundStyle(WeekkeepColors.success)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("paywall.overlineUnknown")
                        .font(.weekkeepBody)
                        .foregroundStyle(WeekkeepColors.success)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Text("paywall.headline")
                    .font(.weekkeepTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Text("paywall.body")
                    .font(.weekkeepBody)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                BenefitRow(icon: "rectangle.stack", text: "paywall.benefitDraft")
                BenefitRow(icon: "lock", text: "paywall.benefitPrivate")
                BenefitRow(icon: "infinity", text: "paywall.benefitLifetime")
                if let feedback {
                    PaywallFeedbackBanner(feedback: feedback)
                }
                if let offering {
                    VStack(alignment: .leading, spacing: WeekkeepSpacing.two) {
                        Text(offering.localizedTitle)
                            .font(.weekkeepHeadline)
                        Text(offering.localizedPrice)
                            .font(.weekkeepTitle2)
                            .accessibilityIdentifier("SHEET-PAY-01-Price")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(WeekkeepSpacing.four)
                    .overlay { RoundedRectangle(cornerRadius: WeekkeepRadii.medium).stroke(WeekkeepColors.subtleBorder, lineWidth: 1) }
                }
                if let continuationTitleKey = restoreState.continuationTitleKey {
                    WeekkeepPrimaryButton(title: LocalizedStringKey(continuationTitleKey)) {
                        continueAfterRestore()
                    }
                    .disabled(isWorking)
                } else if restoreState == .checkingEntitlement {
                    Text("paywall.loading")
                        .font(.weekkeepCallout)
                        .foregroundStyle(WeekkeepColors.secondaryText)
                } else if isLoading {
                    Text("paywall.loading")
                        .font(.weekkeepCallout)
                        .foregroundStyle(WeekkeepColors.secondaryText)
                } else if offering != nil {
                    WeekkeepPrimaryButton(title: "paywall.purchase") {
                        isWorking = true
                        Task {
                            let outcome = await model.environment.purchaseClient.purchasePlus()
                            await model.environment.analyticsClient.capture(.purchaseResolved(result: outcome.analyticsValue, productType: "lifetime", localizedPriceBucket: nil))
                            let resolvedFeedback = await model.purchaseDidResolve(outcome)
                            guard !Task.isCancelled else { return }
                            isWorking = false
                            feedback = resolvedFeedback
                        }
                    }
                    .disabled(isWorking)
                } else {
                    if feedback != .some(.unavailable) {
                        Text("paywall.unavailable")
                            .font(.weekkeepCallout)
                            .foregroundStyle(WeekkeepColors.secondaryText)
                    }
                    WeekkeepSecondaryButton(title: "common.retry") { Task { await loadOffering() } }
                }
                HStack(spacing: WeekkeepSpacing.four) {
                    if restoreState == .idle {
                        Button("paywall.restore") {
                            isWorking = true
                            Task {
                                let outcome = await model.environment.purchaseClient.restore()
                                await model.environment.analyticsClient.capture(.restoreResolved(result: outcome.analyticsValue))
                                let resolvedFeedback = model.restoreDidResolve(outcome)
                                guard !Task.isCancelled else { return }
                                isWorking = false
                                restoreState = outcome == .restored ? .restored : .idle
                                feedback = resolvedFeedback
                            }
                        }
                        .disabled(isWorking)
                    }
                    Link("paywall.terms", destination: AppLinks.terms)
                        .accessibilityIdentifier("SHEET-PAY-01-Terms")
                    Link("paywall.privacy", destination: AppLinks.privacy)
                        .accessibilityIdentifier("SHEET-PAY-01-Privacy")
                }
                .font(.weekkeepCaption)
                .foregroundStyle(WeekkeepColors.secondaryAction)
                .frame(maxWidth: .infinity)
                Text("privacy.storageBody")
                    .font(.weekkeepCaption)
                    .foregroundStyle(WeekkeepColors.secondaryText)
            }
            .padding(.horizontal, screenEdge)
            .padding(.bottom, WeekkeepSpacing.six)
            }
            .scrollIndicators(.hidden)
        }
        .task {
            await capturePaywallViewed()
            await loadOffering()
        }
        .weekkeepScreenBackground()
    }

    private func loadOffering() async {
        isLoading = true
        if feedback == .unavailable {
            feedback = nil
        }
        do {
            offering = try await model.environment.purchaseClient.currentOffering()
        } catch {
            offering = nil
            feedback = .unavailable
        }
        guard !Task.isCancelled else { return }
        isLoading = false
    }

    private func capturePaywallViewed() async {
        guard !hasCapturedView, let savedAlbumCount else { return }
        hasCapturedView = true
        await model.environment.analyticsClient.capture(
            .paywallViewed(freeAlbumCount: savedAlbumCount)
        )
    }

    private func continueAfterRestore() {
        restoreState = .checkingEntitlement
        isWorking = true
        Task {
            let result = await model.continueAfterRestore()
            guard !Task.isCancelled else { return }
            isWorking = false
            switch result {
            case .resumed:
                dismiss()
            case .waitingForEntitlement:
                restoreState = .pending
                feedback = .pending
            }
        }
    }

    private func closePaywall() {
        model.sheet = nil
        dismiss()
        Task { await model.refreshAfterPaywallDismissal() }
    }
}

private struct PaywallFeedbackBanner: View {
    let feedback: PlusPaywallFeedback

    var body: some View {
        Text(LocalizedStringKey(feedback.localizationKey))
            .font(.weekkeepCallout)
            .foregroundStyle(WeekkeepColors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WeekkeepSpacing.four)
            .background(WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
            .overlay {
                RoundedRectangle(cornerRadius: WeekkeepRadii.medium)
                    .stroke(WeekkeepColors.subtleBorder, lineWidth: 1)
            }
            .accessibilityIdentifier(feedback.accessibilityIdentifier)
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        Label(text, systemImage: icon)
            .font(.weekkeepBody)
            .foregroundStyle(WeekkeepColors.primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(WeekkeepSpacing.four)
            .background(WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
            .overlay { RoundedRectangle(cornerRadius: WeekkeepRadii.medium).stroke(WeekkeepColors.subtleBorder, lineWidth: 1) }
    }
}

private extension PurchaseOutcome {
    var analyticsValue: String {
        switch self {
        case .success: "success"
        case .cancelled: "cancelled"
        case .pending: "pending"
        case .failed: "failed"
        }
    }
}

private extension RestoreOutcome {
    var analyticsValue: String {
        switch self {
        case .restored: "success"
        case .noPurchase: "no_purchase"
        case .failed: "failed"
        }
    }
}
