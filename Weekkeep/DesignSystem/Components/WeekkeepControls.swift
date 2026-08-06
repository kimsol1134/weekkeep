import SwiftUI

struct WeekkeepPrimaryButton: View {
    private let title: Text
    private let accessibilityTitle: String
    let action: () -> Void
    var isLoading = false

    init(title: LocalizedStringKey, action: @escaping () -> Void, isLoading: Bool = false) {
        self.title = Text(title)
        self.accessibilityTitle = String(describing: title)
        self.action = action
        self.isLoading = isLoading
    }

    init(renderedTitle: String, action: @escaping () -> Void, isLoading: Bool = false) {
        self.title = Text(verbatim: renderedTitle)
        self.accessibilityTitle = renderedTitle
        self.action = action
        self.isLoading = isLoading
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: WeekkeepSpacing.two) {
                if isLoading { ProgressView().tint(WeekkeepColors.onPrimary) }
                title
                    .font(.weekkeepHeadline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .padding(.horizontal, WeekkeepSpacing.four)
            .foregroundStyle(WeekkeepColors.onPrimary)
            .background(WeekkeepColors.primaryAction, in: RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: WeekkeepRadii.medium))
        .accessibilityIdentifier("CMP-01-PrimaryButton-\(accessibilityTitle)")
    }
}

struct WeekkeepSecondaryButton: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.weekkeepHeadline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, WeekkeepSpacing.four)
                .foregroundStyle(WeekkeepColors.secondaryAction)
                .overlay {
                    RoundedRectangle(cornerRadius: WeekkeepRadii.medium)
                        .stroke(WeekkeepColors.secondaryAction, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("CMP-02-SecondaryButton-\(String(describing: title))")
    }
}

struct PrivacyBadge: View {
    let title: LocalizedStringKey

    var body: some View {
        Label(title, systemImage: "lock.fill")
            .font(.weekkeepCaption)
            .foregroundStyle(WeekkeepColors.secondaryText)
            .labelStyle(.titleAndIcon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, WeekkeepSpacing.one)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("CMP-03-PrivacyBadge")
    }
}

struct WeekkeepWordmark: View {
    var body: some View {
        Image("WeekkeepWordmark")
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 132, height: 34, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("app.name"))
            .accessibilityAddTraits(.isHeader)
    }
}

struct ScreenHeader: View {
    let title: LocalizedStringKey
    var action: (() -> Void)?

    var body: some View {
        HStack {
            if let action {
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(Text("common.back"))
            }
            Text(title)
                .font(.weekkeepNavigation)
                .foregroundStyle(WeekkeepColors.primaryText)
            Spacer()
        }
        .foregroundStyle(WeekkeepColors.primaryText)
    }
}
