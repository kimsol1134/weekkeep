import Foundation

enum PlusPaywallFeedback: String, Equatable, Sendable {
    case cancelled
    case pending
    case failed
    case unavailable
    case restored
    case noPurchase

    var localizationKey: String {
        switch self {
        case .cancelled: "paywall.cancelled"
        case .pending: "paywall.pending"
        case .failed: "paywall.failed"
        case .unavailable: "paywall.unavailable"
        case .restored: "paywall.restored"
        case .noPurchase: "paywall.noPurchase"
        }
    }

    var accessibilityIdentifier: String {
        "SHEET-PAY-01-Outcome-\(rawValue)"
    }
}

enum PlusPaywallRestoreState: Equatable, Sendable {
    case idle
    case restored
    case checkingEntitlement
    case pending

    var suppressesPurchaseAction: Bool {
        self != .idle
    }

    var continuationTitleKey: String? {
        switch self {
        case .idle, .checkingEntitlement:
            nil
        case .restored:
            "paywall.continue"
        case .pending:
            "paywall.checkEntitlement"
        }
    }
}

enum PlusPaywallContinuationResult: Equatable, Sendable {
    case resumed
    case waitingForEntitlement
}
