import SwiftUI

enum SevenStitchRailTone: Sendable, Equatable, CaseIterable {
    case coral
    case plum
    case sage
    case muted
    case progress

    var filledOpacity: Double {
        let opacity: Double
        switch self {
        case .coral, .plum, .progress: opacity = 1
        case .sage: opacity = 0.88
        case .muted: opacity = 0.64
        }
        return max(SevenStitchRail.minimumVisibleOpacity, opacity)
    }

    var remainingOpacity: Double {
        let opacity: Double
        switch self {
        case .coral, .plum: opacity = 0.68
        case .sage: opacity = 0.64
        case .muted: opacity = 0.58
        case .progress: opacity = 0.72
        }
        return max(SevenStitchRail.minimumVisibleOpacity, opacity)
    }
}

struct SevenStitchRailSlot: Equatable, Sendable {
    let index: Int
    let paletteHex: String
    let isFilled: Bool
    let isSelected: Bool
    let opacity: Double
    let width: CGFloat
    let height: CGFloat
}

struct SevenStitchRail: View {
    nonisolated static let stitchCount = 7
    /// The lowest opacity permitted for any visible stitch so the muted rainbow
    /// remains identifiable on-device and at 1080p capture scale.
    nonisolated static let minimumVisibleOpacity: Double = 0.58
    nonisolated static let stitchPaletteHex = WeekkeepColors.sevenStitchPaletteHex
    let filledCount: Int
    let tone: SevenStitchRailTone
    let selectedIndex: Int?
    let vertical: Bool

    init(filledCount: Int = 7, tone: SevenStitchRailTone = .coral, selectedIndex: Int? = nil, vertical: Bool = false) {
        self.filledCount = min(max(filledCount, 0), 7)
        self.tone = tone
        self.selectedIndex = selectedIndex.flatMap { (0..<Self.stitchCount).contains($0) ? $0 : nil }
        self.vertical = vertical
    }

    nonisolated static func slotStates(
        filledCount: Int,
        tone: SevenStitchRailTone,
        selectedIndex: Int?
    ) -> [SevenStitchRailSlot] {
        let clampedFilledCount = min(max(filledCount, 0), stitchCount)
        let validSelectedIndex = selectedIndex.flatMap { (0..<stitchCount).contains($0) ? $0 : nil }

        return (0..<stitchCount).map { index in
            let isFilled = index < clampedFilledCount
            let isSelected = index == validSelectedIndex
            return SevenStitchRailSlot(
                index: index,
                paletteHex: stitchPaletteHex[index],
                isFilled: isFilled,
                isSelected: isSelected,
                opacity: isFilled ? tone.filledOpacity : tone.remainingOpacity,
                width: isSelected ? 4 : 3,
                height: isSelected ? 14 : 10
            )
        }
    }

    var body: some View {
        Group {
            if vertical {
                VStack(spacing: 0) { verticalStitches }
                    .frame(minHeight: 70, idealHeight: 118, maxHeight: .infinity)
            } else {
                HStack(spacing: 0) { horizontalStitches }
                    .frame(minWidth: 44, idealWidth: 118, maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var horizontalStitches: some View {
        ForEach(slots, id: \.index) { slot in
            stitch(slot)
                .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var verticalStitches: some View {
        ForEach(slots, id: \.index) { slot in
            stitch(slot)
                .frame(maxHeight: .infinity)
        }
    }

    private var slots: [SevenStitchRailSlot] {
        Self.slotStates(filledCount: filledCount, tone: tone, selectedIndex: selectedIndex)
    }

    private func stitch(_ slot: SevenStitchRailSlot) -> some View {
        Capsule()
            .fill(WeekkeepColors.sevenStitchPalette[slot.index].opacity(slot.opacity))
            .frame(width: slot.width, height: slot.height)
    }
}

#Preview("Exact seven") {
    VStack(spacing: 30) {
        SevenStitchRail()
        SevenStitchRail(filledCount: 4, tone: .progress)
        SevenStitchRail(tone: .sage)
        SevenStitchRail(vertical: true)
            .frame(height: 160)
    }
    .padding()
    .weekkeepScreenBackground()
}
