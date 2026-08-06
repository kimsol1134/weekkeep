import Foundation
#if canImport(RevenueCat)
import RevenueCat
#endif

enum EntitlementState: String, Sendable, Equatable {
    case unknown
    case inactive
    case active

    var creationAccess: CreationAccess {
        switch self {
        case .unknown: .unknown
        case .inactive: .inactive
        case .active: .active
        }
    }
}

struct PlusOffering: Sendable, Equatable {
    let productID: String
    let localizedTitle: String
    let localizedPrice: String
}

enum PurchaseOutcome: Sendable, Equatable {
    case success
    case cancelled
    case pending
    case failed
}

enum RestoreOutcome: Sendable, Equatable {
    case restored
    case noPurchase
    case failed
}

protocol PurchaseClient: Sendable {
    func entitlementState() async -> EntitlementState
    func currentOffering() async throws -> PlusOffering
    func purchasePlus() async -> PurchaseOutcome
    func restore() async -> RestoreOutcome
}

enum PurchaseClientError: Error, Equatable, Sendable {
    case unavailable
}

enum PurchaseContract {
    static let entitlementID = "plus"
    static let offeringID = "default"
    static let productID = "weekkeep_plus_lifetime"
}

actor DisabledPurchaseClient: PurchaseClient {
    func entitlementState() async -> EntitlementState { .unknown }

    func currentOffering() async throws -> PlusOffering {
        throw PurchaseClientError.unavailable
    }

    func purchasePlus() async -> PurchaseOutcome { .failed }

    func restore() async -> RestoreOutcome { .noPurchase }
}

#if DEBUG
actor FixturePurchaseClient: PurchaseClient {
    private var state: EntitlementState
    private let offering: PlusOffering
    private var nextPurchase: PurchaseOutcome = .success
    private var nextRestore: RestoreOutcome = .noPurchase

    init(
        state: EntitlementState = .inactive,
        offering: PlusOffering? = nil
    ) {
        self.state = state
        self.offering = offering ?? Self.localizedOffering()
    }

    static func localizedOffering(
        preferredLocalization: String = Bundle.main.preferredLocalizations.first ?? "en",
        currencyCode: String = Locale.current.currency?.identifier ?? "USD",
        bundle: Bundle = .main
    ) -> PlusOffering {
        let language = preferredLocalization.hasPrefix("ko") ? "ko" : "en"
        let localizedBundle = bundle.path(forResource: language, ofType: "lproj")
            .flatMap(Bundle.init(path:)) ?? bundle
        let title = localizedBundle.localizedString(
            forKey: "paywall.productFallback",
            value: nil,
            table: nil
        )
        let localizedPrice = currencyCode == "KRW" ? "₩29,000" : "$19.99"
        return PlusOffering(
            productID: PurchaseContract.productID,
            localizedTitle: title,
            localizedPrice: localizedPrice
        )
    }

    func entitlementState() async -> EntitlementState { state }

    func currentOffering() async throws -> PlusOffering { offering }

    func purchasePlus() async -> PurchaseOutcome {
        let result = nextPurchase
        if result == .success { state = .active }
        return result
    }

    func restore() async -> RestoreOutcome {
        let result = nextRestore
        if result == .restored { state = .active }
        return result
    }

    func setPurchaseOutcome(_ outcome: PurchaseOutcome) { nextPurchase = outcome }
    func setRestoreOutcome(_ outcome: RestoreOutcome) { nextRestore = outcome }
}
#endif

#if canImport(RevenueCat)
actor RevenueCatPurchaseClient: PurchaseClient {
    private let isConfigured: Bool

    init(apiKey: String) {
        let normalizedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalizedKey.isEmpty, !Purchases.isConfigured {
            Purchases.configure(withAPIKey: normalizedKey)
        }
        isConfigured = Purchases.isConfigured
    }

    func entitlementState() async -> EntitlementState {
        guard isConfigured else { return .unknown }
        let cachedActive = Purchases.shared.cachedCustomerInfo?.entitlements[PurchaseContract.entitlementID]?.isActive == true
        do {
            let info = try await Purchases.shared.customerInfo()
            return info.entitlements[PurchaseContract.entitlementID]?.isActive == true ? .active : .inactive
        } catch {
            return cachedActive ? .active : .unknown
        }
    }

    func currentOffering() async throws -> PlusOffering {
        let package = try await exactPackage()
        return PlusOffering(
            productID: package.storeProduct.productIdentifier,
            localizedTitle: package.storeProduct.localizedTitle,
            localizedPrice: package.storeProduct.localizedPriceString
        )
    }

    func purchasePlus() async -> PurchaseOutcome {
        do {
            let package = try await exactPackage()
            let result = try await Purchases.shared.purchase(package: package)
            if result.customerInfo.entitlements[PurchaseContract.entitlementID]?.isActive == true { return .success }

            // StoreKit and RevenueCat can deliver the transaction before the
            // entitlement cache is visibly active. Keep the UI locked until
            // the source-of-truth entitlement is confirmed.
            return await entitlementState() == .active ? .success : .pending
        } catch let error as ErrorCode {
            if error == .purchaseCancelledError { return .cancelled }
            if error == .paymentPendingError { return .pending }
            return .failed
        } catch {
            return .failed
        }
    }

    func restore() async -> RestoreOutcome {
        guard isConfigured else { return .failed }
        do {
            let info = try await Purchases.shared.restorePurchases()
            return info.entitlements[PurchaseContract.entitlementID]?.isActive == true ? .restored : .noPurchase
        } catch {
            return .failed
        }
    }

    private func exactPackage() async throws -> RevenueCat.Package {
        guard isConfigured else { throw PurchaseClientError.unavailable }
        let offerings = try await Purchases.shared.offerings()
        guard let offering = offerings.offering(identifier: PurchaseContract.offeringID) else {
            throw PurchaseClientError.unavailable
        }
        guard let package = offering.availablePackages.first(where: { $0.storeProduct.productIdentifier == PurchaseContract.productID }) else {
            throw PurchaseClientError.unavailable
        }
        return package
    }
}
#endif
