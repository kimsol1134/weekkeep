import SwiftUI

enum WeekkeepColors {
    static let ink = Color(red: 0x25 / 255, green: 0x21 / 255, blue: 0x2B / 255)
    static let cream = Color(red: 0xFB / 255, green: 0xF7 / 255, blue: 0xF2 / 255)
    static let paper = Color.white
    static let plum = Color(red: 0x5B / 255, green: 0x41 / 255, blue: 0x5E / 255)
    static let coral = Color(red: 0xE9 / 255, green: 0x7A / 255, blue: 0x68 / 255)
    static let goldenHour = Color(red: 0xE5 / 255, green: 0xA8 / 255, blue: 0x4B / 255)
    static let sage = Color(red: 0x53 / 255, green: 0x77 / 255, blue: 0x63 / 255)
    static let stitchRed = Color(red: 0xE9 / 255, green: 0x7A / 255, blue: 0x68 / 255)
    static let stitchOrange = Color(red: 0xE3 / 255, green: 0x94 / 255, blue: 0x55 / 255)
    static let stitchYellow = Color(red: 0xE5 / 255, green: 0xA8 / 255, blue: 0x4B / 255)
    static let stitchGreen = Color(red: 0x66 / 255, green: 0x83 / 255, blue: 0x6E / 255)
    static let stitchBlue = Color(red: 0x5F / 255, green: 0x87 / 255, blue: 0x9B / 255)
    static let stitchIndigo = Color(red: 0x68 / 255, green: 0x62 / 255, blue: 0x86 / 255)
    static let stitchViolet = Color(red: 0x8A / 255, green: 0x63 / 255, blue: 0x86 / 255)
    static let sevenStitchPalette: [Color] = [
        stitchRed, stitchOrange, stitchYellow, stitchGreen, stitchBlue, stitchIndigo, stitchViolet
    ]
    static let sevenStitchPaletteHex = [
        "#E97A68", "#E39455", "#E5A84B", "#66836E", "#5F879B", "#686286", "#8A6386"
    ]
    static let linen = Color(red: 0xE8 / 255, green: 0xE1 / 255, blue: 0xDB / 255)
    static let secondaryText = Color(red: 0x6F / 255, green: 0x67 / 255, blue: 0x74 / 255)
    static let error = Color(red: 0x9B / 255, green: 0x3D / 255, blue: 0x47 / 255)

    static let primaryBackground = cream
    static let surface = paper
    static let primaryText = ink
    static let secondaryAction = plum
    static let primaryAction = plum
    static let onPrimary = paper
    static let memoryAccent = coral
    static let warmAccent = goldenHour
    static let success = sage
    static let subtleBorder = linen
}

enum WeekkeepSpacing {
    static let one: CGFloat = 4
    static let two: CGFloat = 8
    static let three: CGFloat = 12
    static let four: CGFloat = 16
    static let six: CGFloat = 24
    static let eight: CGFloat = 32
    static let twelve: CGFloat = 48
    static let sixteen: CGFloat = 64
}

/// Root content edge contract for custom screen surfaces.
///
/// The approved 20pt edge applies to regular iPhone widths. The 16pt edge is
/// reserved for compact widths so the smallest supported phones keep enough
/// room for English expansion and 44pt photo targets.
enum WeekkeepScreenLayout {
    static let defaultHorizontalPadding: CGFloat = 20
    static let smallScreenHorizontalPadding: CGFloat = 16
    static let smallScreenWidth: CGFloat = 375

    static func horizontalPadding(for width: CGFloat) -> CGFloat {
        width <= smallScreenWidth
            ? smallScreenHorizontalPadding
            : defaultHorizontalPadding
    }

    static func contentWidth(for width: CGFloat) -> CGFloat {
        max(0, width - (horizontalPadding(for: width) * 2))
    }
}

/// Content runway for custom scroll roots hosted directly by the native
/// floating TabView bar. This is real scroll content space, not a visible
/// replacement for the system tab bar.
enum WeekkeepTabHostSpacing {
    /// Real scroll content runway so the final This Week content can settle
    /// above the native floating tab bar.
    static let bottomScrollClearance = WeekkeepSpacing.sixteen + WeekkeepSpacing.two
}

enum WeekkeepRadii {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let pill: CGFloat = 999
}

enum WeekkeepMotion {
    static let fast: Double = 0.2
    static let standard: Double = 0.32
    static let reveal: Double = 0.48
    static let stagger: Double = 0.07
}
