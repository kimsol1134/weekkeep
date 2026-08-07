import SwiftUI

enum SettingsSemanticRole: String, Equatable, Sendable {
    case neutral
    case success
    case attention
    case error

    static func photoAccess(_ permission: PhotoAuthorization) -> Self {
        switch permission {
        case .authorized: return .success
        case .limited, .notDetermined, .restricted: return .attention
        case .denied: return .error
        }
    }

    static func notification(
        _ status: NotificationAuthorization,
        savedAlbumCount: Int?
    ) -> Self {
        switch status {
        case .denied: return .error
        case .authorized:
            guard let savedAlbumCount, savedAlbumCount > 0 else { return .attention }
            return .success
        case .notDetermined, .provisional, .ephemeral: return .attention
        }
    }

    static func entitlement(_ state: EntitlementState) -> Self {
        switch state {
        case .active: return .success
        case .inactive: return .neutral
        case .unknown: return .attention
        }
    }

    var foregroundColor: Color {
        switch self {
        case .neutral: WeekkeepColors.secondaryText
        case .success: WeekkeepColors.success
        // Golden Hour is used as the accent for attention states. Ink keeps
        // the status text readable at every Dynamic Type size.
        case .attention: WeekkeepColors.primaryText
        case .error: WeekkeepColors.error
        }
    }

    var accentColor: Color {
        switch self {
        case .neutral: WeekkeepColors.secondaryText
        case .success: WeekkeepColors.success
        case .attention: WeekkeepColors.warmAccent
        case .error: WeekkeepColors.error
        }
    }

    var backgroundColor: Color {
        switch self {
        case .neutral: WeekkeepColors.subtleBorder.opacity(0.35)
        case .success: WeekkeepColors.success.opacity(0.12)
        case .attention: WeekkeepColors.warmAccent.opacity(0.16)
        case .error: WeekkeepColors.error.opacity(0.12)
        }
    }

    var symbolName: String {
        switch self {
        case .neutral: "info.circle"
        case .success: "checkmark.circle"
        case .attention: "clock.badge.exclamationmark"
        case .error: "exclamationmark.circle"
        }
    }
}

struct SettingsTabView: View {
    let environment: AppEnvironment
    @State private var model: SettingsModel
    @State private var purchaseModel: WeeklyFlowModel
    @Environment(\.scenePhase) private var scenePhase

    init(environment: AppEnvironment) {
        self.environment = environment
        _model = State(initialValue: SettingsModel(environment: environment))
        _purchaseModel = State(initialValue: WeeklyFlowModel(environment: environment))
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsValueRow(
                        title: "settings.photoAccess",
                        value: LocalizedStringKey(model.photoAccessPresentation.statusKey),
                        role: .photoAccess(model.photoPermission),
                        treatment: .status,
                        action: photoAccessAction
                    )
                    if let explanationKey = model.photoAccessPresentation.explanationKey {
                        SettingsExplanationRow(
                            title: LocalizedStringKey(explanationKey),
                            role: .photoAccess(model.photoPermission)
                        )
                    }
                } header: {
                    SettingsSectionHeader(
                        title: "settings.photos",
                        accessibilityIdentifier: "SCR-SET-01-PhotosSection"
                    )
                }
                Section {
                    SettingsValueRow(
                        title: "settings.weeklyReminder",
                        value: notificationValueLabel,
                        role: .notification(
                            model.notificationStatus,
                            savedAlbumCount: model.savedAlbumCount
                        ),
                        treatment: .status,
                        action: notificationAction
                    )
                    .accessibilityIdentifier("SCR-SET-01-NotificationStatus")
                    if let explanationKey = model.notificationPresentation.explanationKey {
                        SettingsExplanationRow(
                            title: LocalizedStringKey(explanationKey),
                            role: .notification(
                                model.notificationStatus,
                                savedAlbumCount: model.savedAlbumCount
                            )
                        )
                        .accessibilityIdentifier("SCR-SET-01-NotificationGate")
                    }
                } header: {
                    SettingsSectionHeader(
                        title: "settings.notifications",
                        accessibilityIdentifier: "SCR-SET-01-NotificationsSection"
                    )
                }
                Section {
                    SettingsValueRow(
                        title: "settings.status",
                        value: entitlementLabel,
                        role: .entitlement(model.entitlement),
                        treatment: .status,
                        action: plusAction
                    )
                    .accessibilityIdentifier("SHEET-PAY-01-Open")
                    if model.entitlement != .active {
                        SettingsActionRow(title: "settings.restore", action: model.restorePurchase)
                    }
                } header: {
                    SettingsSectionHeader(
                        title: "settings.plus",
                        accessibilityIdentifier: "SCR-SET-01-PlusSection"
                    )
                }
                Section {
                    NavigationLink(value: AppRoute.about) {
                        SettingsNavigationRow(title: "settings.help")
                    }
                    .accessibilityIdentifier("SCR-SET-01-SupportSection")
                }
            }
            .navigationTitle("settings.title")
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .about: AboutSupportView()
                case .album: EmptyView()
                }
            }
            .scrollContentBackground(.hidden)
            .background(WeekkeepColors.primaryBackground)
            .listStyle(.insetGrouped)
            // Keep the final native section header above the floating tab bar
            // without introducing a custom settings surface.
            .listSectionSpacing(0)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: WeekkeepTabHostSpacing.bottomScrollClearance)
                    .accessibilityHidden(true)
            }
        }
        .task { await model.load() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await model.load() }
        }
        .onChange(of: purchaseModel.sheet) { oldValue, newValue in
            if oldValue == .paywall, newValue == nil {
                Task { await model.load() }
            }
        }
        .fullScreenCover(item: purchaseBinding) { _ in
            PlusPaywallView(model: purchaseModel, savedAlbumCount: model.savedAlbumCount)
        }
        .alert("common.done", isPresented: messageBinding) {
            Button("common.done") { model.message = nil }
        } message: {
            Text(LocalizedStringKey(model.message ?? ""))
        }
        .weekkeepScreenBackground()
    }

    private var purchaseBinding: Binding<WeeklySheet?> {
        Binding(
            get: {
                guard let sheet = purchaseModel.sheet else { return nil }
                if case .paywall = sheet { return sheet }
                return nil
            },
            set: { purchaseModel.sheet = $0 }
        )
    }

    private var messageBinding: Binding<Bool> {
        Binding(get: { model.message != nil }, set: { if !$0 { model.message = nil } })
    }

    private var photoAccessAction: (() -> Void)? {
        guard model.photoAccessPresentation.showsAction else { return nil }
        return model.performPhotoAccessAction
    }

    private var notificationAction: (() -> Void)? {
        guard model.notificationPresentation.showsAction else { return nil }
        return model.manageNotifications
    }

    private var plusAction: (() -> Void)? {
        guard model.entitlement == .inactive else { return nil }
        return { purchaseModel.sheet = .paywall }
    }

    private var entitlementLabel: LocalizedStringKey {
        switch model.entitlement {
        case .active: "settings.active"
        case .inactive: "settings.free"
        case .unknown: "curation.analyzing"
        }
    }

    private var notificationValueLabel: LocalizedStringKey {
        LocalizedStringKey(model.notificationPresentation.statusKey)
    }
}

private struct SettingsSectionHeader: View {
    let title: LocalizedStringKey
    let accessibilityIdentifier: String

    var body: some View {
        Text(title)
            .font(.weekkeepHeadline)
            .foregroundStyle(WeekkeepColors.secondaryAction)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier(accessibilityIdentifier)
            .accessibilityAddTraits(.isHeader)
    }
}

private enum SettingsValueTreatment {
    case status
    case supporting
}

private struct SettingsValueRow: View {
    let title: LocalizedStringKey
    let value: LocalizedStringKey
    var role: SettingsSemanticRole = .neutral
    var treatment: SettingsValueTreatment = .supporting
    var action: (() -> Void)?

    var body: some View {
        Group {
            if let action {
                Button(action: action) { content }
            } else {
                content
            }
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        HStack(alignment: .center, spacing: WeekkeepSpacing.two) {
            Text(title)
                .font(.weekkeepBody)
                .foregroundStyle(WeekkeepColors.primaryText)
                .multilineTextAlignment(.leading)
            Spacer()
            SettingsValue(value: value, role: role, treatment: treatment)
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WeekkeepColors.secondaryAction)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
        .listRowBackground(WeekkeepColors.surface)
    }
}

private struct SettingsValue: View {
    let value: LocalizedStringKey
    let role: SettingsSemanticRole
    let treatment: SettingsValueTreatment

    var body: some View {
        Text(value)
            .font(.weekkeepCallout)
            .foregroundStyle(role.foregroundColor)
            .multilineTextAlignment(.trailing)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .layoutPriority(1)
            .modifier(SettingsValueTreatmentModifier(role: role, treatment: treatment))
    }
}

private struct SettingsValueTreatmentModifier: ViewModifier {
    let role: SettingsSemanticRole
    let treatment: SettingsValueTreatment

    @ViewBuilder
    func body(content: Content) -> some View {
        switch treatment {
        case .status:
            content
                .padding(.horizontal, WeekkeepSpacing.two)
                .padding(.vertical, WeekkeepSpacing.one)
                .background(role.backgroundColor, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(role.accentColor.opacity(0.34), lineWidth: 1)
                }
        case .supporting:
            content
        }
    }
}

private struct SettingsNavigationRow: View {
    let title: LocalizedStringKey

    var body: some View {
        HStack {
            Text(title)
                .font(.weekkeepBody)
                .foregroundStyle(WeekkeepColors.primaryText)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(WeekkeepColors.secondaryAction)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
        .listRowBackground(WeekkeepColors.surface)
    }
}

private struct SettingsActionRow: View {
    let title: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.weekkeepBody)
                    .foregroundStyle(WeekkeepColors.secondaryAction)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WeekkeepColors.secondaryAction)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(WeekkeepColors.surface)
    }
}

private struct SettingsExplanationRow: View {
    let title: LocalizedStringKey
    let role: SettingsSemanticRole

    var body: some View {
        HStack(alignment: .top, spacing: WeekkeepSpacing.two) {
            Image(systemName: role.symbolName)
                .font(.weekkeepCallout)
                .foregroundStyle(role.accentColor)
                .frame(width: 22, height: 22)
            Text(title)
                .font(.weekkeepCallout)
                .foregroundStyle(WeekkeepColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .listRowBackground(WeekkeepColors.surface)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

struct AboutSupportView: View {
    var body: some View {
        List {
            Section {
                AboutLinkRow(title: "about.help", destination: AppLinks.support)
                AboutLinkRow(title: "about.contact", destination: AppLinks.contact)
                AboutLinkRow(title: "about.terms", destination: AppLinks.terms)
                AboutLinkRow(title: "about.privacy", destination: AppLinks.privacy)
            } footer: {
                Text(WeekkeepLocalization.string("settings.version", WeekkeepLocalization.appVersion))
                    .font(.weekkeepCaption)
                    .foregroundStyle(WeekkeepColors.secondaryText)
                    .textCase(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .scrollContentBackground(.hidden)
        .background(WeekkeepColors.primaryBackground)
        .listStyle(.insetGrouped)
        .listSectionSpacing(0)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: WeekkeepTabHostSpacing.bottomScrollClearance)
                .accessibilityHidden(true)
        }
        .navigationTitle("about.title")
        .navigationBarTitleDisplayMode(.inline)
        .weekkeepScreenBackground()
    }
}

private struct AboutLinkRow: View {
    let title: LocalizedStringKey
    let destination: URL

    var body: some View {
        Link(destination: destination) {
            AboutRowLabel(title: title)
        }
        .listRowBackground(WeekkeepColors.surface)
    }
}

private struct AboutRowLabel: View {
    let title: LocalizedStringKey

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(WeekkeepColors.secondaryText)
        }
        .font(.weekkeepBody)
        .foregroundStyle(WeekkeepColors.primaryText)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
    }
}
