import SwiftUI

enum WeekkeepTabIconKind: String, CaseIterable, Sendable {
    case week = "ThisWeekTabIcon"
    case archive = "WeeksTabIcon"
    case settings = "SettingsTabIcon"

    var assetName: String { rawValue }

    var silhouetteID: String {
        switch self {
        case .week: "calendar"
        case .archive: "album-stack"
        case .settings: "sliders"
        }
    }
}

struct WeekkeepTabIcon: View {
    nonisolated static let assetNames = WeekkeepTabIconKind.allCases.map(\.assetName)
    nonisolated static let silhouetteIDs = WeekkeepTabIconKind.allCases.map(\.silhouetteID)
    nonisolated static let inactiveOpacity = 0.72
    nonisolated static let usesOriginalRendering = true

    let kind: WeekkeepTabIconKind
    let isSelected: Bool

    var body: some View {
        Image(kind.assetName)
            .renderingMode(.original)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 28, height: 24)
            .opacity(isSelected ? 1 : Self.inactiveOpacity)
            .accessibilityHidden(true)
    }
}
