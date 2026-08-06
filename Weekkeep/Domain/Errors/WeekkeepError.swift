import Foundation

enum WeekkeepError: Error, Equatable, Sendable {
    case permission(PhotoPermissionIssue)
    case noEligiblePhotos
    case photoFetch
    case analysis
    case cancellation
    case persistence
    case purchase
    case notification
}
