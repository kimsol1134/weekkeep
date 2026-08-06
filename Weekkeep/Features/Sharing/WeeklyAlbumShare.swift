import Foundation
import ImageIO
import LinkPresentation
import SwiftUI
import UIKit

enum WeeklyAlbumShareFormat: String, CaseIterable, Identifiable, Sendable {
    case story
    case post

    var id: String { rawValue }

    var pixelSize: CGSize {
        switch self {
        case .story: CGSize(width: 1_080, height: 1_920)
        case .post: CGSize(width: 1_080, height: 1_350)
        }
    }

    var fileName: String { "weekkeep-" + rawValue + ".jpg" }

    var analyticsValue: ShareArtifactFormatAnalyticsValue {
        switch self {
        case .story: .story
        case .post: .post
        }
    }
}

enum WeeklyAlbumShareRenderError: Error, Equatable, Sendable {
    case missingWordmark
    case noAvailablePhotos
    case invalidPhotoData
}

/// A deterministic, local-only renderer for the saved album share artifact.
/// It accepts image bytes supplied by PhotoKit and never receives a filename,
/// location, score, or Photos identifier for drawing or metadata.
@MainActor
struct WeeklyAlbumShareRenderer {
    let locale: Locale
    let timeZone: TimeZone
    let wordmarkImage: UIImage?

    init(
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        wordmarkImage: UIImage? = UIImage(named: "WeekkeepWordmark")
    ) {
        self.locale = locale
        self.timeZone = timeZone
        self.wordmarkImage = wordmarkImage
    }

    func render(
        album: WeeklyAlbumSnapshot,
        images: [PhotoID: PhotoImageData],
        format: WeeklyAlbumShareFormat
    ) throws -> Data {
        guard let wordmarkImage else { throw WeeklyAlbumShareRenderError.missingWordmark }

        let orderedImages = album.photos
            .sorted { $0.position < $1.position }
            .compactMap { photo -> UIImage? in
                guard let data = images[photo.assetLocalIdentifier]?.data,
                      let image = UIImage(data: data) else { return nil }
                return image
            }
        guard !orderedImages.isEmpty else { throw WeeklyAlbumShareRenderError.noAvailablePhotos }

        let canvas = format.pixelSize
        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1
        rendererFormat.opaque = true
        let renderer = UIGraphicsImageRenderer(size: canvas, format: rendererFormat)

        return renderer.jpegData(withCompressionQuality: 0.92) { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor(WeekkeepColors.cream).cgColor)
            cgContext.fill(CGRect(origin: .zero, size: canvas))

            drawHeader(
                in: cgContext,
                canvas: canvas,
                wordmark: wordmarkImage,
                dateRange: dateRangeText(for: album)
            )

            let frames = Self.layoutFrames(photoCount: orderedImages.count, canvasSize: canvas)
            for (image, frame) in zip(orderedImages, frames) {
                drawPhoto(image, in: frame, context: cgContext)
            }

            drawFooter(in: cgContext, canvas: canvas)
        }
    }

    /// Returns one stable frame per real image. Seven images use the approved
    /// hero+2+4 editorial composition; smaller albums use only real slots.
    nonisolated static func layoutFrames(photoCount: Int, canvasSize: CGSize) -> [CGRect] {
        let count = min(max(photoCount, 0), 7)
        guard count > 0 else { return [] }

        let margin = min(canvasSize.width * 0.067, 72)
        let gap = min(canvasSize.width * 0.015, 16)
        let top = canvasSize.height * 0.18
        let bottom = canvasSize.height * 0.15
        let contentWidth = canvasSize.width - (margin * 2)
        let contentHeight = max(canvasSize.height - top - bottom, 100)
        let twoColumnWidth = (contentWidth - gap) / 2

        switch count {
        case 1:
            let width = min(contentWidth, contentHeight * 0.8)
            let height = width / 0.8
            return [CGRect(
                x: margin + ((contentWidth - width) / 2),
                y: top + ((contentHeight - min(height, contentHeight)) / 2),
                width: width,
                height: min(height, contentHeight)
            )]
        case 2:
            let side = min(twoColumnWidth, contentHeight)
            let y = top + ((contentHeight - side) / 2)
            return [
                CGRect(x: margin, y: y, width: side, height: side),
                CGRect(x: margin + side + gap, y: y, width: side, height: side)
            ]
        case 3:
            let heroHeight = min(contentHeight * 0.58, contentWidth * 0.68)
            let lowerSide = min(twoColumnWidth, contentHeight - heroHeight - gap)
            let lowerY = top + heroHeight + gap
            return [
                CGRect(x: margin, y: top, width: contentWidth, height: heroHeight),
                CGRect(x: margin, y: lowerY, width: lowerSide, height: lowerSide),
                CGRect(x: margin + lowerSide + gap, y: lowerY, width: lowerSide, height: lowerSide)
            ]
        case 4:
            let side = min(twoColumnWidth, (contentHeight - gap) / 2)
            return twoColumnFrames(
                count: 4,
                side: side,
                margin: margin,
                gap: gap,
                top: top
            )
        case 5, 6:
            let side = min(twoColumnWidth, (contentHeight - (gap * CGFloat((count + 1) / 2 - 1))) / CGFloat((count + 1) / 2))
            return (0..<count).map { index in
                let row = index / 2
                let column = index % 2
                return CGRect(
                    x: margin + CGFloat(column) * (side + gap),
                    y: top + CGFloat(row) * (side + gap),
                    width: side,
                    height: side
                )
            }
        default:
            let heroHeight = contentHeight * 0.42
            let middleHeight = contentHeight * 0.25
            let lowerHeight = contentHeight - heroHeight - middleHeight - (gap * 2)
            let middleWidth = (contentWidth - gap) / 2
            let lowerWidth = (contentWidth - (gap * 3)) / 4
            let middleY = top + heroHeight + gap
            let lowerY = middleY + middleHeight + gap
            return [
                CGRect(x: margin, y: top, width: contentWidth, height: heroHeight),
                CGRect(x: margin, y: middleY, width: middleWidth, height: middleHeight),
                CGRect(x: margin + middleWidth + gap, y: middleY, width: middleWidth, height: middleHeight),
                CGRect(x: margin, y: lowerY, width: lowerWidth, height: lowerHeight),
                CGRect(x: margin + (lowerWidth + gap), y: lowerY, width: lowerWidth, height: lowerHeight),
                CGRect(x: margin + (lowerWidth + gap) * 2, y: lowerY, width: lowerWidth, height: lowerHeight),
                CGRect(x: margin + (lowerWidth + gap) * 3, y: lowerY, width: lowerWidth, height: lowerHeight)
            ]
        }
    }

    private nonisolated static func twoColumnFrames(
        count: Int,
        side: CGFloat,
        margin: CGFloat,
        gap: CGFloat,
        top: CGFloat
    ) -> [CGRect] {
        (0..<count).map { index in
            let row = index / 2
            let column = index % 2
            return CGRect(
                x: margin + CGFloat(column) * (side + gap),
                y: top + CGFloat(row) * (side + gap),
                width: side,
                height: side
            )
        }
    }

    private func dateRangeText(for album: WeeklyAlbumSnapshot) -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = locale
        calendar.timeZone = timeZone
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        let endDate = calendar.date(byAdding: .day, value: -1, to: album.weekEnd) ?? album.weekEnd
        return formatter.string(from: album.weekStart) + " – " + formatter.string(from: endDate)
    }

    private func drawHeader(
        in context: CGContext,
        canvas: CGSize,
        wordmark: UIImage,
        dateRange: String
    ) {
        let margin = min(canvas.width * 0.067, 72)
        let wordmarkWidth = min(canvas.width * 0.34, 340)
        let wordmarkHeight = wordmarkWidth * (wordmark.size.height / max(wordmark.size.width, 1))
        wordmark.draw(in: CGRect(x: margin, y: canvas.height * 0.065, width: wordmarkWidth, height: wordmarkHeight))

        drawText(
            dateRange,
            in: CGRect(x: margin, y: canvas.height * 0.125, width: canvas.width - (margin * 2), height: 42),
            font: .weekkeepExportHeadline,
            color: UIColor(WeekkeepColors.plum),
            alignment: .left,
            context: context
        )
    }

    private func drawFooter(in context: CGContext, canvas: CGSize) {
        let margin = min(canvas.width * 0.067, 72)
        let footerY = canvas.height - (canvas.height * 0.09)
        let stitches = WeekkeepColors.sevenStitchPaletteHex.map(UIColor.init(hex:))
        let stitchWidth: CGFloat = 7
        let stitchHeight: CGFloat = 24
        let stitchGap: CGFloat = 9
        let railWidth = (CGFloat(stitches.count) * stitchWidth) + (CGFloat(stitches.count - 1) * stitchGap)
        let railX = (canvas.width - railWidth) / 2

        for (index, color) in stitches.enumerated() {
            let rect = CGRect(
                x: railX + CGFloat(index) * (stitchWidth + stitchGap),
                y: footerY - stitchHeight - 10,
                width: stitchWidth,
                height: stitchHeight
            )
            context.setFillColor(color.cgColor)
            context.addPath(CGPath(roundedRect: rect, cornerWidth: stitchWidth / 2, cornerHeight: stitchWidth / 2, transform: nil))
            context.fillPath()
        }

        drawText(
            "Made with Weekkeep",
            in: CGRect(x: margin, y: footerY, width: canvas.width - (margin * 2), height: 34),
            font: .weekkeepExportCaption,
            color: UIColor(WeekkeepColors.secondaryText),
            alignment: .center,
            context: context
        )
    }

    private func drawPhoto(_ image: UIImage, in frame: CGRect, context: CGContext) {
        let radius: CGFloat = 24
        let path = CGPath(roundedRect: frame, cornerWidth: radius, cornerHeight: radius, transform: nil)
        context.saveGState()
        context.addPath(path)
        context.clip()

        let imageSize = image.size
        let scale = max(frame.width / max(imageSize.width, 1), frame.height / max(imageSize.height, 1))
        let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let drawRect = CGRect(
            x: frame.midX - (drawSize.width / 2),
            y: frame.midY - (drawSize.height / 2),
            width: drawSize.width,
            height: drawSize.height
        )
        image.draw(in: drawRect)
        context.restoreGState()

        context.setStrokeColor(UIColor(WeekkeepColors.linen).cgColor)
        context.setLineWidth(2)
        context.addPath(path)
        context.strokePath()
    }

    private func drawText(
        _ text: String,
        in rect: CGRect,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment,
        context: CGContext
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        paragraph.lineBreakMode = .byTruncatingTail
        (text as NSString).draw(
            in: rect,
            withAttributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraph
            ]
        )
        _ = context
    }
}

enum WeeklyAlbumShareFileStore {
    static func writeTemporaryArtifact(_ data: Data, format: WeeklyAlbumShareFormat) throws -> URL {
        let directory = artifactDirectory
        // A previous process can be terminated before SwiftUI's onDisappear
        // cleanup runs. A new explicit export therefore clears stale local
        // artifacts before writing the one file the share sheet needs.
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent(format.fileName)
        try data.write(to: url, options: .atomic)
        return url
    }

    static func removeTemporaryArtifact(at url: URL?) {
        guard let url else { return }
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: artifactDirectory)
    }

    private static var artifactDirectory: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("WeekkeepShare", isDirectory: true)
    }
}

enum WeeklyAlbumSharePreparationState: Equatable, Sendable {
    case idle
    case loading
    case ready
    case failed
}

private struct WeeklyAlbumSharePreparationKey: Equatable {
    let format: WeeklyAlbumShareFormat
    let revision: Int
}

enum ShareSheetAnalyticsGate {
    static func eventIfNeeded(
        didCapture: inout Bool,
        format: ShareArtifactFormatAnalyticsValue,
        entryPoint: ShareEntryPointAnalyticsValue
    ) -> AnalyticsEvent? {
        guard !didCapture else { return nil }
        didCapture = true
        return .shareSheetOpened(format: format, entryPoint: entryPoint)
    }

    static func reset(_ didCapture: inout Bool) {
        didCapture = false
    }
}

/// Supplies the native share sheet with a branded local preview without
/// adding a public URL, recipient, or any Photos metadata to the activity
/// item. The file URL remains the actual item delivered to the chosen app.
final class WeeklyAlbumShareActivityItemSource: NSObject, UIActivityItemSource {
    let artifactURL: URL
    let previewData: Data
    let title: String

    init(artifactURL: URL, previewData: Data, title: String) {
        self.artifactURL = artifactURL
        self.previewData = previewData
        self.title = title
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        _ = activityViewController
        return artifactURL
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        _ = activityViewController
        _ = activityType
        return artifactURL
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        subjectForActivityType activityType: UIActivity.ActivityType?
    ) -> String {
        _ = activityViewController
        _ = activityType
        return title
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        thumbnailImageForActivityType activityType: UIActivity.ActivityType?,
        suggestedSize size: CGSize
    ) -> UIImage? {
        _ = activityViewController
        _ = activityType
        _ = size
        return UIImage(data: previewData)
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        _ = activityViewController
        let metadata = LPLinkMetadata()
        metadata.title = title
        if let image = UIImage(data: previewData) {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        // Deliberately leave both URL fields empty. Weekkeep has no approved
        // public install URL in V1, and a local share must not imply one.
        return metadata
    }
}

enum WeeklyAlbumShareSpacing {
    static let rootSection = WeekkeepSpacing.six
}

struct WeeklyAlbumShareView: View {
    let album: WeeklyAlbumSnapshot
    let environment: AppEnvironment
    let entryPoint: ShareEntryPointAnalyticsValue

    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: WeeklyAlbumShareFormat = .story
    @State private var preparationState: WeeklyAlbumSharePreparationState = .idle
    @State private var previewData: Data?
    @State private var artifactURL: URL?
    @State private var isPresentingActivity = false
    @State private var didCaptureShareSheetOpen = false
    @State private var preparationRevision = 0

    var body: some View {
        GeometryReader { proxy in
            let screenEdge = WeekkeepScreenLayout.horizontalPadding(for: proxy.size.width)

            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: WeekkeepSpacing.four) {
                        Text("share.title")
                            .font(.weekkeepTitle2)
                            .accessibilityIdentifier("SHEET-SHARE-01-Title")
                        Text("share.body")
                            .font(.weekkeepBody)
                        Text(WeekkeepLocalization.dateRange(start: album.weekStart, end: album.weekEnd))
                            .font(.weekkeepCallout)
                            .foregroundStyle(WeekkeepColors.secondaryText)

                        Picker("share.format", selection: $selectedFormat) {
                            Text("share.story").tag(WeeklyAlbumShareFormat.story)
                            Text("share.post").tag(WeeklyAlbumShareFormat.post)
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel(Text("share.format"))
                        .accessibilityIdentifier("SHEET-SHARE-01-FormatPicker")

                        content
                            .padding(.top, WeeklyAlbumShareSpacing.rootSection)
                    }
                    .padding(.horizontal, screenEdge)
                    .padding(.vertical, WeekkeepSpacing.four)
                }
                .navigationTitle("share.navigationTitle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.close") { dismiss() }
                            .accessibilityIdentifier("SHEET-SHARE-01-Close")
                    }
                }
            }
        }
        .task(id: WeeklyAlbumSharePreparationKey(format: selectedFormat, revision: preparationRevision)) {
            await prepare()
        }
        .onDisappear { cleanupArtifact() }
        .sheet(isPresented: $isPresentingActivity, onDismiss: shareSheetDidDismiss) {
            if let activityItemSource {
                NativeShareSheet(items: [activityItemSource])
            }
        }
        .weekkeepScreenBackground()
    }

    @ViewBuilder
    private var content: some View {
        switch preparationState {
        case .idle, .loading:
            VStack(spacing: WeekkeepSpacing.three) {
                ProgressView()
                    .tint(WeekkeepColors.primaryAction)
                Text("share.loading")
                    .font(.weekkeepCallout)
                    .foregroundStyle(WeekkeepColors.secondaryText)
            }
            .frame(maxWidth: .infinity, minHeight: 360)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("SHEET-SHARE-01-Loading")
        case .failed:
            VStack(alignment: .leading, spacing: WeekkeepSpacing.three) {
                Text("share.error")
                    .font(.weekkeepBody)
                WeekkeepPrimaryButton(title: "share.retry") { preparationRevision += 1 }
                    .accessibilityIdentifier("SHEET-SHARE-01-Retry")
            }
            .padding(WeekkeepSpacing.six)
            .background(WeekkeepColors.surface, in: RoundedRectangle(cornerRadius: WeekkeepRadii.large))
        case .ready:
            VStack(alignment: .leading, spacing: WeekkeepSpacing.four) {
                if let previewData, let image = UIImage(data: previewData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: WeekkeepRadii.large))
                        .accessibilityLabel(Text("share.previewLabel"))
                        .accessibilityIdentifier("SHEET-SHARE-01-Preview")
                }
                Text("share.privacy")
                    .font(.weekkeepCaption)
                    .foregroundStyle(WeekkeepColors.secondaryText)
                WeekkeepPrimaryButton(title: "share.share") {
                    guard activityItemSource != nil else { return }
                    if let event = ShareSheetAnalyticsGate.eventIfNeeded(
                        didCapture: &didCaptureShareSheetOpen,
                        format: selectedFormat.analyticsValue,
                        entryPoint: entryPoint
                    ) {
                        Task { await environment.analyticsClient.capture(event) }
                    }
                    isPresentingActivity = true
                }
                .accessibilityIdentifier("SHEET-SHARE-01-Share")
            }
        }
    }

    private var activityItemSource: WeeklyAlbumShareActivityItemSource? {
        guard let artifactURL, let previewData else { return nil }
        return WeeklyAlbumShareActivityItemSource(
            artifactURL: artifactURL,
            previewData: previewData,
            title: WeekkeepLocalization.string("share.title")
        )
    }

    private func prepare() async {
        cleanupArtifact()
        preparationState = .loading
        previewData = nil

        do {
            var images: [PhotoID: PhotoImageData] = [:]
            for photo in album.photos.sorted(by: { $0.position < $1.position }) where photo.isAvailable {
                guard !Task.isCancelled else { return }
                do {
                    let image = try await environment.photoLibrary.displayImage(
                        for: photo.assetLocalIdentifier,
                        targetSize: CGSize(width: 1_080, height: 1_080)
                    )
                    images[photo.assetLocalIdentifier] = image
                } catch {
                    // A deleted or iCloud-unavailable source is omitted from
                    // the adaptive export rather than replaced with fake data.
                }
            }

            let renderer = WeeklyAlbumShareRenderer()
            let data = try renderer.render(album: album, images: images, format: selectedFormat)
            guard !Task.isCancelled else { return }
            let url = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(data, format: selectedFormat)
            previewData = data
            artifactURL = url
            preparationState = .ready
        } catch is CancellationError {
            return
        } catch {
            preparationState = .failed
        }
    }

    private func cleanupArtifact() {
        WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: artifactURL)
        artifactURL = nil
    }

    private func shareSheetDidDismiss() {
        ShareSheetAnalyticsGate.reset(&didCaptureShareSheetOpen)
        cleanupArtifact()
        // The native activity controller consumes the one temporary file. A
        // parent may intentionally share the same saved week again, so make
        // view-bound task prepare the next presentation. Incrementing the key
        // also means SwiftUI cancels that work if this view disappears.
        preparationRevision += 1
    }
}

struct NativeShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        _ = context
        _ = uiViewController
    }
}

private extension UIFont {
    static var weekkeepExportHeadline: UIFont {
        UIFont(name: "LINESeedKR-Bd", size: 30) ?? .systemFont(ofSize: 30, weight: .semibold)
    }

    static var weekkeepExportCaption: UIFont {
        UIFont(name: "LINESeedKR-Rg", size: 24) ?? .systemFont(ofSize: 24, weight: .regular)
    }
}

private extension UIColor {
    convenience init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: value)
        var integer: UInt64 = 0
        scanner.scanHexInt64(&integer)
        self.init(
            red: CGFloat((integer >> 16) & 0xFF) / 255,
            green: CGFloat((integer >> 8) & 0xFF) / 255,
            blue: CGFloat(integer & 0xFF) / 255,
            alpha: 1
        )
    }
}
