import SwiftUI

enum AppTab: String, CaseIterable, Hashable, Sendable {
    case week
    case archive
    case settings

    var titleKey: LocalizedStringKey {
        switch self {
        case .week: "tab.week"
        case .archive: "tab.archive"
        case .settings: "tab.settings"
        }
    }
}

enum AppRoute: Hashable, Sendable {
    case album(weekKey: String)
    case privacy
    case about
}

enum AppSheet: Identifiable, Equatable, Sendable {
    case privacyExplanation
    case notificationPrimer
    case paywall

    var id: String {
        switch self {
        case .privacyExplanation: "privacyExplanation"
        case .notificationPrimer: "notificationPrimer"
        case .paywall: "paywall"
        }
    }
}

enum AppDeepLink: Equatable, Sendable {
    case weeklyCurrent
    case album(weekKey: String)
    case photoSettings
    case notificationSettings
    case plus
}

struct AppRouter: Sendable {
    func parse(_ url: URL) -> AppDeepLink? {
        guard url.scheme == "weekkeep",
              url.user == nil,
              url.password == nil,
              url.port == nil,
              url.query == nil,
              url.fragment == nil,
              let host = url.host else {
            return nil
        }

        switch (host, url.path) {
        case ("weekly", "/current"):
            return .weeklyCurrent
        case ("album", let path):
            let key = String(path.dropFirst())
            guard path.first == "/",
                  !key.isEmpty,
                  !key.contains("/"),
                  key.range(of: #"^\d{4}-W\d{2}$"#, options: .regularExpression) != nil else {
                return nil
            }
            return .album(weekKey: key)
        case ("settings", "/photos"):
            return .photoSettings
        case ("settings", "/notifications"):
            return .notificationSettings
        case ("plus", ""):
            return .plus
        default:
            return nil
        }
    }

    func tab(for link: AppDeepLink) -> AppTab {
        switch link {
        case .album:
            .archive
        case .photoSettings, .notificationSettings:
            .settings
        case .weeklyCurrent, .plus:
            .week
        }
    }

    @MainActor
    func route(_ link: AppDeepLink, in environment: AppEnvironment) {
        environment.pendingDeepLink = link
        environment.selectedTab = tab(for: link)
    }
}
