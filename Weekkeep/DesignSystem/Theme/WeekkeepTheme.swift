import SwiftUI
import UIKit

struct WeekkeepTheme {
    let colors = WeekkeepColors.self
    let spacing = WeekkeepSpacing.self
    let radii = WeekkeepRadii.self
    let motion = WeekkeepMotion.self
}

struct WeekkeepSystemSafeAreaResolver {
    static let statusBarBreathingRoom: CGFloat = 8
    static let compactPortraitHeightUpperBound: CGFloat = 700
    static let expandedPortraitAspectRatioThreshold: CGFloat = 2.167
    static let compactPortraitBoundary: CGFloat = 28
    static let notchPortraitBoundary: CGFloat = 55
    static let expandedPortraitBoundary: CGFloat = 62

    /// Resolves the top boundary without consulting UIKit or a device model.
    /// Runtime measurements always win; geometry is only a launch-time
    /// fallback for the iOS 26 edge-to-edge zero-runtime case.
    static func resolve(
        statusBarHeight: CGFloat,
        windowSafeAreaTop: CGFloat,
        portraitScreenSize: CGSize
    ) -> CGFloat {
        let statusBarHeight = max(0, statusBarHeight)
        let windowSafeAreaTop = max(0, windowSafeAreaTop)

        if statusBarHeight > 0 || windowSafeAreaTop > 0 {
            return max(
                windowSafeAreaTop,
                statusBarHeight + statusBarBreathingRoom
            )
        }

        return fallbackTop(for: portraitScreenSize)
    }

    /// Uses normalized portrait geometry bands rather than model identifiers.
    /// The compact height band covers home-button phones, the expanded aspect
    /// ratio band covers the larger modern top system region, and the
    /// remaining portrait sizes use the older notch boundary.
    static func fallbackTop(for screenSize: CGSize) -> CGFloat {
        let width = max(0, min(screenSize.width, screenSize.height))
        let height = max(0, max(screenSize.width, screenSize.height))

        guard width > 0, height > 0 else {
            // A zero-sized launch frame is transient. Keep the conservative
            // fallback until RootView receives its first real geometry.
            return expandedPortraitBoundary
        }

        if height <= compactPortraitHeightUpperBound {
            return compactPortraitBoundary
        }

        let portraitAspectRatio = height / width
        if portraitAspectRatio >= expandedPortraitAspectRatioThreshold {
            return expandedPortraitBoundary
        }

        return notchPortraitBoundary
    }
}

@MainActor
enum WeekkeepSystemSafeArea {
    // iOS 26 may report an edge-to-edge app window with zero
    // safe-area/status-manager height while the system status indicators are
    // still composited above the window. RootView supplies geometry so the
    // resolver does not need UIScreen.main during launch.
    static func top(for screenSize: CGSize, geometrySafeAreaTop: CGFloat = 0) -> CGFloat {
        let activeScenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }

        let statusBarHeight = activeScenes
            .compactMap { $0.statusBarManager?.statusBarFrame.height }
            .max() ?? 0
        let windowSafeAreaTop = max(
            geometrySafeAreaTop,
            activeScenes
                .flatMap { $0.windows }
                .map { $0.safeAreaInsets.top }
                .max() ?? 0
        )
        let sceneScreenSize = activeScenes
            .map { $0.screen.bounds.size }
            .max { lhs, rhs in
                (lhs.width * lhs.height) < (rhs.width * rhs.height)
            }
        let fallbackScreenSize = isUsable(screenSize) ? screenSize : (sceneScreenSize ?? .zero)

        return WeekkeepSystemSafeAreaResolver.resolve(
            statusBarHeight: statusBarHeight,
            windowSafeAreaTop: windowSafeAreaTop,
            portraitScreenSize: fallbackScreenSize
        )
    }

    private static func isUsable(_ size: CGSize) -> Bool {
        size.width > 0 && size.height > 0
    }
}

/// Pure geometry for masking content that can scroll into the system status
/// region. The modifier keeps the mask out of layout, hit testing, and the
/// accessibility tree.
enum WeekkeepTopSystemOcclusion {
    static func height(windowSafeAreaTop: CGFloat, localSafeAreaTop: CGFloat) -> CGFloat {
        max(0, max(windowSafeAreaTop, localSafeAreaTop))
    }
}

private struct WeekkeepTopSystemOcclusionModifier: ViewModifier {
    let localSafeAreaTop: CGFloat
    @Environment(\.weekkeepWindowSafeAreaTop) private var windowSafeAreaTop

    func body(content: Content) -> some View {
        let occlusionHeight = WeekkeepTopSystemOcclusion.height(
            windowSafeAreaTop: windowSafeAreaTop,
            localSafeAreaTop: localSafeAreaTop
        )

        content.overlay(alignment: .top) {
            WeekkeepColors.primaryBackground
                .frame(maxWidth: .infinity)
                .frame(height: occlusionHeight)
                .offset(y: -occlusionHeight)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

/// Masks only the unsafe top/status region while leaving scroll geometry
/// unchanged. Callers provide their local runtime safe-area measurement; the
/// root-injected boundary remains the other side of the same max calculation.
extension View {
    func weekkeepTopSystemOcclusion(localSafeAreaTop: CGFloat) -> some View {
        modifier(WeekkeepTopSystemOcclusionModifier(localSafeAreaTop: localSafeAreaTop))
    }
}

extension EnvironmentValues {
    @Entry var weekkeepTheme = WeekkeepTheme()
    @Entry var weekkeepWindowSafeAreaTop: CGFloat = 0
}

extension View {
    func weekkeepTheme(_ theme: WeekkeepTheme = WeekkeepTheme()) -> some View {
        environment(\.weekkeepTheme, theme)
    }
}
