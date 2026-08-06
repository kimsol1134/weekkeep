import Foundation

struct PermissionBlockedPresentation: Equatable, Sendable {
    let titleKey: String
    let bodyKey: String
    let iconName: String
    let showsSettingsAction: Bool

    private init(
        titleKey: String,
        bodyKey: String,
        iconName: String,
        showsSettingsAction: Bool
    ) {
        self.titleKey = titleKey
        self.bodyKey = bodyKey
        self.iconName = iconName
        self.showsSettingsAction = showsSettingsAction
    }

    init(issue: PhotoPermissionIssue) {
        switch issue {
        case .denied:
            self.init(
                titleKey: "week.permissionTitle",
                bodyKey: "week.permissionBody",
                iconName: "photo.badge.exclamationmark",
                showsSettingsAction: true
            )
        case .restricted:
            self.init(
                titleKey: "week.restrictedTitle",
                bodyKey: "week.restrictedBody",
                iconName: "lock.shield",
                showsSettingsAction: false
            )
        }
    }
}
