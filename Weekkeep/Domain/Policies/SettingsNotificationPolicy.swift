import Foundation

enum SettingsNotificationAction: String, Equatable, Sendable {
    case none
    case requestAuthorization
    case openSettings
}

struct SettingsNotificationPresentation: Equatable, Sendable {
    let statusKey: String
    let explanationKey: String?
    let actionTitleKey: String?
    let action: SettingsNotificationAction

    init(notificationStatus: NotificationAuthorization, savedAlbumCount: Int?) {
        guard let savedAlbumCount else {
            self.init(
                statusKey: "settings.reminderChecking",
                explanationKey: nil,
                actionTitleKey: nil,
                action: .none
            )
            return
        }

        guard savedAlbumCount > 0 else {
            self.init(
                statusKey: "settings.reminderAvailableAfterSave",
                explanationKey: "settings.reminderRequiresSavedAlbum",
                actionTitleKey: nil,
                action: .none
            )
            return
        }

        switch notificationStatus {
        case .notDetermined:
            self.init(
                statusKey: "settings.reminderNotSet",
                explanationKey: nil,
                actionTitleKey: "settings.enableReminder",
                action: .requestAuthorization
            )
        case .authorized, .provisional, .denied, .ephemeral:
            self.init(
                statusKey: notificationStatus == .denied ? "settings.reminderOff" : "settings.monday",
                explanationKey: nil,
                actionTitleKey: "settings.openNotificationSettings",
                action: .openSettings
            )
        }
    }

    var showsAction: Bool {
        action != .none
    }

    private init(
        statusKey: String,
        explanationKey: String?,
        actionTitleKey: String?,
        action: SettingsNotificationAction
    ) {
        self.statusKey = statusKey
        self.explanationKey = explanationKey
        self.actionTitleKey = actionTitleKey
        self.action = action
    }
}
