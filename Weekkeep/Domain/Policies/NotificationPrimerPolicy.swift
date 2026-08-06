import Foundation

enum NotificationPrimerPolicy {
    static func shouldOfferAfterSave(
        notificationStatus: NotificationAuthorization,
        primerShown: Bool
    ) -> Bool {
        !primerShown && notificationStatus == .notDetermined
    }

    static func shouldRequestAuthorization(
        currentStatus: NotificationAuthorization
    ) -> Bool {
        currentStatus == .notDetermined
    }
}
