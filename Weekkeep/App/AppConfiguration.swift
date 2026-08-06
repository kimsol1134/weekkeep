import Foundation

struct AppConfiguration: Sendable, Equatable {
    static let euPostHogHost = URL(string: "https://eu.i.posthog.com")!

    let purchasesEnabled: Bool
    let revenueCatAPIKey: String
    let analyticsEnabled: Bool
    let postHogProjectToken: String
    let postHogHost: URL

    init(infoDictionary: [String: Any]) {
        purchasesEnabled = Self.boolValue(infoDictionary[Keys.purchasesEnabled])
        revenueCatAPIKey = Self.stringValue(infoDictionary[Keys.revenueCatAPIKey])
        analyticsEnabled = Self.boolValue(infoDictionary[Keys.analyticsEnabled])
        postHogProjectToken = Self.stringValue(infoDictionary[Keys.postHogProjectToken])
        postHogHost = Self.urlValue(infoDictionary[Keys.postHogHost])
    }

    init(
        purchasesEnabled: Bool,
        revenueCatAPIKey: String = "",
        analyticsEnabled: Bool,
        postHogProjectToken: String = "",
        postHogHost: URL = AppConfiguration.euPostHogHost
    ) {
        self.purchasesEnabled = purchasesEnabled
        self.revenueCatAPIKey = revenueCatAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.analyticsEnabled = analyticsEnabled
        self.postHogProjectToken = postHogProjectToken.trimmingCharacters(in: .whitespacesAndNewlines)
        self.postHogHost = postHogHost
    }

    static var bundle: AppConfiguration {
        AppConfiguration(infoDictionary: Bundle.main.infoDictionary ?? [:])
    }

    var hasValidPurchaseConfiguration: Bool {
        purchasesEnabled && !revenueCatAPIKey.isEmpty
    }

    var hasValidAnalyticsConfiguration: Bool {
        analyticsEnabled && !postHogProjectToken.isEmpty && postHogHost == Self.euPostHogHost
    }

    private enum Keys {
        static let purchasesEnabled = "WK_PURCHASES_ENABLED"
        static let revenueCatAPIKey = "WK_REVENUECAT_API_KEY"
        static let analyticsEnabled = "WK_ANALYTICS_ENABLED"
        static let postHogProjectToken = "WK_POSTHOG_PROJECT_TOKEN"
        static let postHogHost = "WK_POSTHOG_HOST"
    }

    private static func stringValue(_ value: Any?) -> String {
        switch value {
        case let string as String:
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        case let number as NSNumber:
            return number.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        default:
            return ""
        }
    }

    private static func boolValue(_ value: Any?) -> Bool {
        if let number = value as? NSNumber { return number.boolValue }
        return switch stringValue(value).lowercased() {
        case "yes", "true", "1": true
        default: false
        }
    }

    private static func urlValue(_ value: Any?) -> URL {
        let raw = stringValue(value)
        guard let url = URL(string: raw), url.scheme == "https", url.host != nil else {
            return euPostHogHost
        }
        return url == euPostHogHost ? url : euPostHogHost
    }
}
