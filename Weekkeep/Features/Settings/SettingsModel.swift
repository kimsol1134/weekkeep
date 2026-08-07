import Foundation
import Observation
import UIKit

enum SettingsPhotoAccessAction: String, Equatable, Sendable {
    case none
    case requestAuthorization
    case openSettings
}

struct SettingsPhotoAccessPresentation: Equatable, Sendable {
    let statusKey: String
    let explanationKey: String?
    let actionTitleKey: String?
    let action: SettingsPhotoAccessAction

    init(permission: PhotoAuthorization) {
        switch permission {
        case .notDetermined:
            self.init(
                statusKey: "settings.notDeterminedAccess",
                explanationKey: nil,
                actionTitleKey: "settings.requestPhotoAccess",
                action: .requestAuthorization
            )
        case .authorized:
            self.init(
                statusKey: "settings.fullAccess",
                explanationKey: nil,
                actionTitleKey: "settings.manageAccess",
                action: .openSettings
            )
        case .limited:
            self.init(
                statusKey: "settings.limitedAccess",
                explanationKey: nil,
                actionTitleKey: "settings.manageAccess",
                action: .openSettings
            )
        case .denied:
            self.init(
                statusKey: "settings.deniedAccess",
                explanationKey: nil,
                actionTitleKey: "common.openSettings",
                action: .openSettings
            )
        case .restricted:
            self.init(
                statusKey: "settings.restrictedAccess",
                explanationKey: "week.restrictedBody",
                actionTitleKey: nil,
                action: .none
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
        action: SettingsPhotoAccessAction
    ) {
        self.statusKey = statusKey
        self.explanationKey = explanationKey
        self.actionTitleKey = actionTitleKey
        self.action = action
    }
}

@MainActor
@Observable
final class SettingsModel {
    let environment: AppEnvironment
    var photoPermission: PhotoAuthorization = .notDetermined
    var notificationStatus: NotificationAuthorization = .notDetermined
    var entitlement: EntitlementState = .unknown
    private(set) var savedAlbumCount: Int? = nil
    var message: String?

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    var photoAccessPresentation: SettingsPhotoAccessPresentation {
        SettingsPhotoAccessPresentation(permission: photoPermission)
    }

    var notificationPresentation: SettingsNotificationPresentation {
        SettingsNotificationPresentation(
            notificationStatus: notificationStatus,
            savedAlbumCount: savedAlbumCount
        )
    }

    func load() async {
        await refreshPhotoPermission()
        notificationStatus = await environment.notificationClient.authorizationStatus()
        entitlement = await environment.purchaseClient.entitlementState()
        savedAlbumCount = try? await environment.albumStore.savedAlbumCount()
        if (savedAlbumCount ?? 0) > 0,
           notificationStatus == .authorized || notificationStatus == .provisional {
            await scheduleRemindersIfPossible()
        }
    }

    func refreshPhotoPermission() async {
        photoPermission = await environment.photoLibrary.authorizationStatus()
    }

    func performPhotoAccessAction() {
        switch photoAccessPresentation.action {
        case .none:
            break
        case .openSettings:
            openPhotosSettings()
        case .requestAuthorization:
            Task { await requestPhotoAccess() }
        }
    }

    func requestPhotoAccess() async {
        let status = await environment.photoLibrary.requestAuthorization()
        await environment.analyticsClient.capture(.photoPermissionResolved(status: status.analyticsValue))
        await refreshPhotoPermission()
    }

    func openPhotosSettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }

    func manageNotifications() {
        switch notificationPresentation.action {
        case .none:
            return
        case .openSettings:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            return
        case .requestAuthorization:
            break
        }

        Task {
            let status = await environment.notificationClient.requestAuthorization()
            environment.notificationPrimerShown = true
            notificationStatus = status
            await environment.analyticsClient.capture(.notificationPermissionResolved(status: status.rawValue))
            if status == .authorized || status == .provisional {
                await scheduleRemindersIfPossible()
            }
        }
    }

    func restorePurchase() {
        Task {
            let result = await environment.purchaseClient.restore()
            await environment.analyticsClient.capture(.restoreResolved(result: result.analyticsValue))
            switch result {
            case .restored:
                let confirmedEntitlement = await environment.purchaseClient.entitlementState()
                entitlement = confirmedEntitlement
                message = confirmedEntitlement == .active ? "paywall.restored" : "paywall.pending"
            case .noPurchase:
                message = "paywall.noPurchase"
            case .failed:
                message = "paywall.failed"
            }
        }
    }

    private func scheduleRemindersIfPossible() async {
        guard (savedAlbumCount ?? 0) > 0 else { return }
        guard let cycle = environment.regularCycleStartsAt else { return }
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: environment.weekCalculator.timeZoneIdentifier) ?? .current
        try? await environment.notificationClient.scheduleWeeklyReminders(
            now: Date(),
            regularCycleStartsAt: cycle,
            calendar: calendar
        )
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
