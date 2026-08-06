import SwiftUI
import UIKit

struct PhotoThumbnailView: View {
    let photo: PhotoReference
    let photoLibrary: any PhotoLibraryClient
    var contentMode: ContentMode = .fill
    @State private var image: UIImage?
    @State private var failed = false

    init(photo: PhotoReference, photoLibrary: any PhotoLibraryClient, contentMode: ContentMode = .fill) {
        self.photo = photo
        self.photoLibrary = photoLibrary
        self.contentMode = contentMode
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if failed {
                unavailableView
            } else {
                placeholderView
            }
        }
        .clipped()
        .task(id: photo.id.rawValue) {
            image = nil
            failed = false
            do {
                let result = try await photoLibrary.displayImage(for: photo.id, targetSize: CGSize(width: 720, height: 720))
                guard !Task.isCancelled else { return }
                image = UIImage(data: result.data)
                failed = image == nil
            } catch {
                guard !Task.isCancelled else { return }
                failed = true
            }
        }
    }

    private var placeholderView: some View {
        WeekkeepColors.linen
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 24, weight: .light))
                .foregroundStyle(WeekkeepColors.secondaryText.opacity(0.65))
        }
        .redacted(reason: .placeholder)
    }

    private var unavailableView: some View {
        WeekkeepColors.linen
            .overlay {
                VStack(spacing: WeekkeepSpacing.two) {
                    Image(systemName: "photo.badge.exclamationmark")
                    Text("review.missing")
                        .font(.weekkeepCaption)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(WeekkeepColors.secondaryText)
                .padding(WeekkeepSpacing.two)
            }
    }
}

private struct PhotoTileAspectLayout: Layout {
    let aspectRatio: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard let subview = subviews.first else { return .zero }

        let intrinsicSize = subview.sizeThatFits(.unspecified)
        let width: CGFloat
        if let proposedWidth = proposal.width, proposedWidth.isFinite {
            width = proposedWidth
        } else if let proposedHeight = proposal.height, proposedHeight.isFinite {
            width = proposedHeight * aspectRatio
        } else {
            width = intrinsicSize.width
        }

        return CGSize(width: width, height: width / aspectRatio)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else { return }
        subview.place(
            at: CGPoint(x: bounds.midX, y: bounds.midY),
            anchor: .center,
            proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
        )
    }
}

struct PhotoTile: View {
    let photo: PhotoReference
    let index: Int
    let total: Int
    let photoLibrary: any PhotoLibraryClient
    let isSelected: Bool
    let onTap: () -> Void
    let onView: () -> Void
    let onReplace: () -> Void
    let aspectRatio: CGFloat

    init(
        photo: PhotoReference,
        index: Int,
        total: Int,
        photoLibrary: any PhotoLibraryClient,
        isSelected: Bool,
        onTap: @escaping () -> Void,
        onView: @escaping () -> Void,
        onReplace: @escaping () -> Void,
        aspectRatio: CGFloat = 1
    ) {
        self.photo = photo
        self.index = index
        self.total = total
        self.photoLibrary = photoLibrary
        self.isSelected = isSelected
        self.onTap = onTap
        self.onView = onView
        self.onReplace = onReplace
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        PhotoTileAspectLayout(aspectRatio: aspectRatio) {
            GeometryReader { proxy in
                Button(action: onTap) {
                    ZStack {
                        Color.clear
                        PhotoThumbnailView(photo: photo, photoLibrary: photoLibrary)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
                            .overlay {
                                RoundedRectangle(cornerRadius: WeekkeepRadii.small)
                                    .stroke(isSelected ? WeekkeepColors.memoryAccent : WeekkeepColors.subtleBorder, lineWidth: isSelected ? 3 : 1)
                            }
                            .overlay(alignment: .bottomTrailing) {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(WeekkeepColors.primaryText)
                                        .frame(width: 28, height: 28)
                                        .background(WeekkeepColors.paper, in: Circle())
                                        .padding(WeekkeepSpacing.two)
                                        .accessibilityHidden(true)
                                }
                            }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .buttonStyle(.plain)
            .contentShape(RoundedRectangle(cornerRadius: WeekkeepRadii.small))
            .frame(minWidth: WeeklyPhotoGridLayout.minimumTileWidth, minHeight: WeeklyPhotoGridLayout.minimumTileWidth)
            .accessibilityLabel(Text(WeekkeepLocalization.string("accessibility.photo", total, index + 1)))
            .accessibilityValue(Text(isSelected ? "review.selected" : ""))
            .accessibilityHint(Text("review.helper"))
            .accessibilityAction(named: Text("accessibility.view"), onView)
            .accessibilityAction(named: Text("accessibility.replace"), onReplace)
            .accessibilityIdentifier("CMP-05-PhotoTile-\(index)")
        }
    }
}

struct WeeklyPhotoGrid: View {
    let photos: [PhotoReference]
    let photoLibrary: any PhotoLibraryClient
    let selectedIndex: Int?
    let onTap: (Int) -> Void
    let onView: (Int) -> Void
    let onReplace: (Int) -> Void
    let spacing: CGFloat

    init(
        photos: [PhotoReference],
        photoLibrary: any PhotoLibraryClient,
        selectedIndex: Int?,
        onTap: @escaping (Int) -> Void,
        onView: @escaping (Int) -> Void,
        onReplace: @escaping (Int) -> Void,
        spacing: CGFloat = WeekkeepSpacing.two
    ) {
        self.photos = photos
        self.photoLibrary = photoLibrary
        self.selectedIndex = selectedIndex
        self.onTap = onTap
        self.onView = onView
        self.onReplace = onReplace
        self.spacing = spacing
    }

    var body: some View {
        Group {
            switch photos.count {
            case 0:
                EmptyView()
            case 1:
                tile(at: 0, aspectRatio: 4 / 5)
            case 2:
                HStack(spacing: spacing) { tile(at: 0); tile(at: 1) }
            case 3:
                VStack(spacing: spacing) {
                    tile(at: 0, aspectRatio: WeeklyPhotoGridLayout.heroAspectRatio)
                    HStack(spacing: spacing) { tile(at: 1); tile(at: 2) }
                }
            case 4:
                LazyVGrid(columns: columns(2), spacing: spacing) {
                    ForEach(0..<4, id: \.self) { index in tile(at: index) }
                }
            case 5, 6:
                LazyVGrid(columns: columns(2), spacing: spacing) {
                    ForEach(photos.indices, id: \.self) { index in tile(at: index) }
                }
            case 7:
                VStack(spacing: spacing) {
                    tile(at: 0, aspectRatio: WeeklyPhotoGridLayout.heroAspectRatio)
                    HStack(spacing: spacing) {
                        tile(at: 1)
                        tile(at: 2)
                    }
                    AdaptiveSevenPhotoLayout(spacing: spacing) {
                        ForEach(3..<min(7, photos.count), id: \.self) { index in tile(at: index) }
                    }
                }
            default:
                LazyVGrid(columns: columns(2), spacing: spacing) {
                    ForEach(photos.indices, id: \.self) { index in tile(at: index) }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("CMP-04-WeeklyPhotoGrid")
    }

    private func tile(at index: Int, aspectRatio: CGFloat = 1) -> some View {
        PhotoTile(
            photo: photos[index],
            index: index,
            total: photos.count,
            photoLibrary: photoLibrary,
            isSelected: selectedIndex == index,
            onTap: { onTap(index) },
            onView: { onView(index) },
            onReplace: { onReplace(index) },
            aspectRatio: aspectRatio
        )
    }

    private func columns(_ count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 44), spacing: spacing), count: count)
    }
}

struct AdaptiveSevenPhotoLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let minimumWidth = WeeklyPhotoGridLayout.minimumWidth(for: 2, spacing: spacing)
        let width = max(proposal.width ?? WeeklyPhotoGridLayout.minimumWidth(for: 4, spacing: spacing), minimumWidth)
        let columnCount = WeeklyPhotoGridLayout.preferredSevenPhotoColumnCount(
            availableWidth: width,
            spacing: spacing
        )
        let cellWidth = cellWidth(for: width, columnCount: columnCount)
        let rowCount = (subviews.count + columnCount - 1) / columnCount
        let height = (CGFloat(rowCount) * cellWidth)
            + (CGFloat(max(rowCount - 1, 0)) * spacing)
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let columnCount = WeeklyPhotoGridLayout.preferredSevenPhotoColumnCount(
            availableWidth: bounds.width,
            spacing: spacing
        )
        let cellWidth = cellWidth(for: bounds.width, columnCount: columnCount)
        for index in subviews.indices {
            let row = index / columnCount
            let column = index % columnCount
            let origin = CGPoint(
                x: bounds.minX + CGFloat(column) * (cellWidth + spacing),
                y: bounds.minY + CGFloat(row) * (cellWidth + spacing)
            )
            subviews[index].place(
                at: CGPoint(x: origin.x + (cellWidth / 2), y: origin.y + (cellWidth / 2)),
                anchor: .center,
                proposal: ProposedViewSize(width: cellWidth, height: cellWidth)
            )
        }
    }

    private func cellWidth(for width: CGFloat, columnCount: Int) -> CGFloat {
        max(
            WeeklyPhotoGridLayout.minimumTileWidth,
            (width - (CGFloat(columnCount - 1) * spacing)) / CGFloat(columnCount)
        )
    }
}

enum WeeklyPhotoGridLayout {
    static let minimumTileWidth: CGFloat = 44
    static let gridSpacing: CGFloat = WeekkeepSpacing.two
    static let heroAspectRatio: CGFloat = 16 / 10

    static func minimumWidth(for columnCount: Int, spacing: CGFloat) -> CGFloat {
        guard columnCount > 0 else { return 0 }
        return (CGFloat(columnCount) * minimumTileWidth)
            + (CGFloat(max(columnCount - 1, 0)) * spacing)
    }

    static func preferredSevenPhotoColumnCount(availableWidth: CGFloat, spacing: CGFloat) -> Int {
        availableWidth >= minimumWidth(for: 4, spacing: spacing) ? 4 : 2
    }

    struct SevenPhotoGeometry: Equatable {
        let hero: CGRect
        let middle: [CGRect]
        let bottom: [CGRect]

        var allFrames: [CGRect] { [hero] + middle + bottom }

        var totalHeight: CGFloat {
            allFrames.map(\.maxY).max() ?? 0
        }
    }

    static func sevenPhotoGeometry(
        availableWidth: CGFloat,
        spacing: CGFloat = WeeklyPhotoGridLayout.gridSpacing
    ) -> SevenPhotoGeometry {
        let width = max(availableWidth, 0)
        let gap = max(spacing, 0)
        let heroHeight = width / heroAspectRatio
        let hero = CGRect(x: 0, y: 0, width: width, height: heroHeight)

        let middleWidth = max((width - gap) / 2, 0)
        let middleY = hero.maxY + gap
        let middle = (0..<2).map { index in
            CGRect(
                x: CGFloat(index) * (middleWidth + gap),
                y: middleY,
                width: middleWidth,
                height: middleWidth
            )
        }

        let columnCount = preferredSevenPhotoColumnCount(availableWidth: width, spacing: gap)
        let bottomWidth = max((width - CGFloat(columnCount - 1) * gap) / CGFloat(columnCount), 0)
        let bottomY = middleY + middleWidth + gap
        let bottom = (0..<4).map { index in
            let row = index / columnCount
            let column = index % columnCount
            return CGRect(
                x: CGFloat(column) * (bottomWidth + gap),
                y: bottomY + CGFloat(row) * (bottomWidth + gap),
                width: bottomWidth,
                height: bottomWidth
            )
        }

        return SevenPhotoGeometry(hero: hero, middle: middle, bottom: bottom)
    }
}
