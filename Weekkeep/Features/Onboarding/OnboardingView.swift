import SwiftUI

struct OnboardingView: View {
    let environment: AppEnvironment
    @State private var isRequesting = false
    @State private var showPrivacy = false

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)
            let contentWidth = WeekkeepScreenLayout.contentWidth(for: proxy.size.width)

            ScrollView {
                VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                    WeekkeepWordmark()
                        .padding(.top, WeekkeepSpacing.twelve)

                    SevenStitchRail()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, WeekkeepSpacing.two)

                    Text("onboarding.headline")
                        .font(.weekkeepDisplay)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    Text("onboarding.body")
                        .font(.weekkeepBody)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)

                    OnboardingKeepsakePreview(width: contentWidth)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(Text("accessibility.onboardingPreview"))
                        .accessibilityIdentifier("CMP-04-OnboardingKeepsakePreview")

                    PrivacyBadge(title: "onboarding.privacy")

                    WeekkeepPrimaryButton(title: "onboarding.primary", action: begin, isLoading: isRequesting)
                        .disabled(isRequesting)
                        .accessibilityIdentifier("SCR-ONB-01-Primary")

                    Button("onboarding.secondary") { showPrivacy = true }
                        .font(.weekkeepHeadline)
                        .foregroundStyle(WeekkeepColors.secondaryAction)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, WeekkeepSpacing.twelve)
                        .accessibilityIdentifier("SCR-ONB-01-PrivacyLink")
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, screenEdge)
            }
        }
        .scrollIndicators(.hidden)
        .weekkeepScreenBackground()
        .sheet(isPresented: $showPrivacy) {
            OnboardingPrivacySheet()
                .presentationDetents([.medium, .large])
        }
    }

    private func begin() {
        isRequesting = true
        Task { @MainActor in
            await environment.analyticsClient.capture(.onboardingStarted(
                locale: Locale.current.identifier,
                appVersion: WeekkeepLocalization.appVersion
            ))
            let status = await environment.photoLibrary.requestAuthorization()
            await environment.analyticsClient.capture(.photoPermissionResolved(status: status.rawValue))
            environment.onboardingCompleted = true
            environment.shouldStartWelcomeCuration = status.accessScope != nil
            isRequesting = false
        }
    }
}

enum OnboardingKeepsakePreviewContract {
    static let fixtureIndices = Array(0..<SamplePhotoFixtures.assetNames.count)
}

private struct OnboardingKeepsakePreview: View {
    let width: CGFloat

    var body: some View {
        FixturePhotoStory(style: .onboarding)
        .frame(width: width, alignment: .leading)
    }
}

private struct OnboardingPrivacySheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
            HStack {
                Text("onboarding.privacyTitle")
                    .font(.weekkeepTitle2)
                Spacer()
                Button("common.close") { dismiss() }
                    .font(.weekkeepCallout)
            }
            Text("onboarding.privacyDetail")
                .font(.weekkeepBody)
                .fixedSize(horizontal: false, vertical: true)
            PrivacyBadge(title: "onboarding.privacy")
            Spacer()
        }
        .padding(WeekkeepSpacing.six)
        .foregroundStyle(WeekkeepColors.primaryText)
        .weekkeepScreenBackground()
    }
}
