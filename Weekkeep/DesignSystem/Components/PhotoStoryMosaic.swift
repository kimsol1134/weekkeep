import SwiftUI

enum FixturePhotoStoryStyle: Equatable, Sendable {
    case onboarding
    case compact

    var outerPadding: CGFloat {
        switch self {
        case .onboarding: WeekkeepSpacing.four
        case .compact: WeekkeepSpacing.four
        }
    }

    var railWidth: CGFloat {
        switch self {
        case .onboarding: WeekkeepSpacing.four
        case .compact: 0
        }
    }

    var railGap: CGFloat {
        switch self {
        case .onboarding: WeekkeepSpacing.three
        case .compact: 0
        }
    }

    var railHeight: CGFloat {
        switch self {
        case .onboarding: 0
        case .compact: 18
        }
    }
}

/// A static, photo-first story used only to explain the product with the
/// approved fictional fixture photos. Onboarding uses a more breathable
/// 1+3+3 album page; compact surfaces retain the review/share hero+2+4
/// geometry. Neither variant uses overlap or decorative placeholder art.
struct FixturePhotoStory: View {
    let style: FixturePhotoStoryStyle

    var body: some View {
        Group {
            if style == .onboarding {
                FixturePhotoStoryLayout(style: style) {
                    SevenStitchRail(vertical: true)
                    FixturePhotoMosaic(style: style)
                }
            } else {
                VStack(alignment: .leading, spacing: style.railGap) {
                    SevenStitchRail()
                        .frame(maxWidth: .infinity)
                        .frame(height: style.railHeight)
                        .zIndex(1)
                    FixturePhotoMosaic(style: style)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(style.outerPadding)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.large))
        .background(WeekkeepColors.paper, in: RoundedRectangle(cornerRadius: WeekkeepRadii.large))
        .overlay {
            RoundedRectangle(cornerRadius: WeekkeepRadii.large)
                .stroke(WeekkeepColors.subtleBorder, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("accessibility.photoStory"))
    }
}

private struct FixturePhotoStoryLayout: Layout {
    let style: FixturePhotoStoryStyle

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let width = max(proposal.width ?? 320, 0)
        let mosaicWidth = max(
            width - (style.outerPadding * 2) - style.railWidth - style.railGap,
            0
        )
        let mosaicHeight = FixturePhotoStoryGeometry.geometry(
            for: style,
            availableWidth: mosaicWidth
        ).totalHeight
        let railHeight = style == .compact ? style.railHeight + style.railGap : 0
        return CGSize(
            width: width,
            height: style.outerPadding * 2 + railHeight + mosaicHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard subviews.count == 2 else { return }

        let width = max(bounds.width, 0)
        let mosaicWidth = max(
            width - (style.outerPadding * 2) - style.railWidth - style.railGap,
            0
        )
        let mosaicHeight = FixturePhotoStoryGeometry.geometry(
            for: style,
            availableWidth: mosaicWidth
        ).totalHeight

        switch style {
        case .onboarding:
            subviews[0].place(
                at: CGPoint(
                    x: bounds.minX + style.outerPadding,
                    y: bounds.minY + style.outerPadding
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: style.railWidth, height: mosaicHeight)
            )
            subviews[1].place(
                at: CGPoint(
                    x: bounds.minX + style.outerPadding + style.railWidth + style.railGap,
                    y: bounds.minY + style.outerPadding
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: mosaicWidth, height: mosaicHeight)
            )
        case .compact:
            subviews[0].place(
                at: CGPoint(
                    x: bounds.minX + style.outerPadding,
                    y: bounds.minY + style.outerPadding
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: width - (style.outerPadding * 2), height: style.railHeight)
            )
            subviews[1].place(
                at: CGPoint(
                    x: bounds.minX + style.outerPadding,
                    y: bounds.minY + style.outerPadding + style.railHeight + style.railGap
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: width - (style.outerPadding * 2), height: mosaicHeight)
            )
        }
    }
}

private struct FixturePhotoMosaic: View {
    let style: FixturePhotoStoryStyle

    var body: some View {
        switch style {
        case .onboarding:
            VStack(spacing: FixturePhotoStoryGeometry.onboardingGutter) {
                FixturePhotoImage(
                    index: 0,
                    aspectRatio: WeeklyPhotoGridLayout.heroAspectRatio
                )

                fixtureRow(indices: 1..<4, spacing: FixturePhotoStoryGeometry.onboardingGutter)
                fixtureRow(indices: 4..<7, spacing: FixturePhotoStoryGeometry.onboardingGutter)
            }
        case .compact:
            VStack(spacing: FixturePhotoStoryGeometry.compactGutter) {
                FixturePhotoImage(
                    index: 0,
                    aspectRatio: WeeklyPhotoGridLayout.heroAspectRatio
                )

                HStack(spacing: FixturePhotoStoryGeometry.compactGutter) {
                    FixturePhotoImage(index: 1)
                    FixturePhotoImage(index: 2)
                }

                ViewThatFits(in: .horizontal) {
                    compactBottomGrid(columnCount: 4)
                    compactBottomGrid(columnCount: 2)
                }
            }
        }
    }

    private func fixtureRow(indices: Range<Int>, spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(indices, id: \.self) { index in
                FixturePhotoImage(index: index)
            }
        }
    }

    private func compactBottomGrid(columnCount: Int) -> some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(
                    .flexible(minimum: WeeklyPhotoGridLayout.minimumTileWidth),
                    spacing: FixturePhotoStoryGeometry.compactGutter
                ),
                count: columnCount
            ),
            spacing: FixturePhotoStoryGeometry.compactGutter
        ) {
            ForEach(3..<7, id: \.self) { index in
                FixturePhotoImage(index: index)
            }
        }
    }
}

/// Geometry contract for the explanatory photo story.
///
/// The onboarding page has a distinct, generous 1+3+3 composition so its
/// seven fixtures read as one calm album page. Compact explanatory surfaces
/// intentionally keep the established hero+2+4 composition used by review
/// and share previews.
enum FixturePhotoStoryGeometry {
    static let onboardingGutter = WeekkeepSpacing.three
    static let compactGutter = WeeklyPhotoGridLayout.gridSpacing

    static func geometry(
        for style: FixturePhotoStoryStyle,
        availableWidth: CGFloat
    ) -> WeeklyPhotoGridLayout.SevenPhotoGeometry {
        switch style {
        case .onboarding:
            onboardingGeometry(availableWidth: availableWidth)
        case .compact:
            WeeklyPhotoGridLayout.sevenPhotoGeometry(
                availableWidth: availableWidth,
                spacing: compactGutter
            )
        }
    }

    static func onboardingGeometry(
        availableWidth: CGFloat,
        spacing: CGFloat = onboardingGutter
    ) -> WeeklyPhotoGridLayout.SevenPhotoGeometry {
        let width = max(availableWidth, 0)
        let gutter = max(spacing, onboardingGutter)
        let hero = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: width / WeeklyPhotoGridLayout.heroAspectRatio
        )

        let thumbnailWidth = max((width - (gutter * 2)) / 3, 0)
        let firstRowY = hero.maxY + gutter
        let firstRow = (0..<3).map { index in
            CGRect(
                x: CGFloat(index) * (thumbnailWidth + gutter),
                y: firstRowY,
                width: thumbnailWidth,
                height: thumbnailWidth
            )
        }

        let secondRowY = firstRowY + thumbnailWidth + gutter
        let secondRow = (0..<3).map { index in
            CGRect(
                x: CGFloat(index) * (thumbnailWidth + gutter),
                y: secondRowY,
                width: thumbnailWidth,
                height: thumbnailWidth
            )
        }

        return WeeklyPhotoGridLayout.SevenPhotoGeometry(
            hero: hero,
            middle: firstRow,
            bottom: secondRow
        )
    }
}

private struct FixturePhotoImage: View {
    let index: Int
    let aspectRatio: CGFloat

    init(index: Int, aspectRatio: CGFloat = 1) {
        self.index = index
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        Rectangle()
            .fill(.clear)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                Image(SamplePhotoFixtures.assetName(for: index))
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
            .accessibilityHidden(true)
    }
}
