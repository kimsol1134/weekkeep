import CoreGraphics
import Foundation
import ImageIO
import UIKit
import XCTest
@testable import Weekkeep

@MainActor
final class WeeklyAlbumShareRendererTests: XCTestCase {
    func testStoryAndPostUseExactOutputDimensionsAndNonemptyJPEG() throws {
        let album = makeAlbum(photoCount: 7)
        let images = makeImages(for: album)
        let renderer = WeeklyAlbumShareRenderer(
            locale: Locale(identifier: "en_US"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
            wordmarkImage: makeWordmarkImage()
        )

        let story = try renderer.render(album: album, images: images, format: .story)
        let post = try renderer.render(album: album, images: images, format: .post)

        XCTAssertGreaterThan(story.count, 1_000)
        XCTAssertGreaterThan(post.count, 1_000)
        XCTAssertEqual(imageSize(for: story), CGSize(width: 1_080, height: 1_920))
        XCTAssertEqual(imageSize(for: post), CGSize(width: 1_080, height: 1_350))
    }

    func testSevenPhotoLayoutKeepsHeroTwoAndFourEditorialGroups() {
        let frames = WeeklyAlbumShareRenderer.layoutFrames(
            photoCount: 7,
            canvasSize: WeeklyAlbumShareFormat.story.pixelSize
        )

        XCTAssertEqual(frames.count, 7)
        XCTAssertEqual(frames, WeeklyAlbumShareRenderer.layoutFrames(
            photoCount: 7,
            canvasSize: WeeklyAlbumShareFormat.story.pixelSize
        ))
        XCTAssertGreaterThan(frames[0].width, frames[1].width)
        XCTAssertEqual(frames[1].width, frames[2].width, accuracy: 0.001)
        XCTAssertEqual(frames[3].width, frames[4].width, accuracy: 0.001)
        XCTAssertEqual(frames[4].width, frames[5].width, accuracy: 0.001)
        XCTAssertEqual(frames[5].width, frames[6].width, accuracy: 0.001)

        for lhsIndex in frames.indices {
            for rhsIndex in frames.indices where rhsIndex > lhsIndex {
                XCTAssertFalse(frames[lhsIndex].intersects(frames[rhsIndex]))
            }
        }
    }

    func testFewerThanSevenPhotosUseOnlyRealAdaptiveSlots() throws {
        let album = makeAlbum(photoCount: 3)
        let images = makeImages(for: album)
        let renderer = WeeklyAlbumShareRenderer(wordmarkImage: makeWordmarkImage())
        let data = try renderer.render(album: album, images: images, format: .post)

        XCTAssertEqual(WeeklyAlbumShareRenderer.layoutFrames(photoCount: 3, canvasSize: WeeklyAlbumShareFormat.post.pixelSize).count, 3)
        XCTAssertGreaterThan(data.count, 1_000)
    }

    func testRendererDoesNotCarryPhotoIdentifiersOrPrivateImageMetadata() throws {
        let album = makeAlbum(photoCount: 7)
        let images = makeImages(for: album)
        let renderer = WeeklyAlbumShareRenderer(wordmarkImage: makeWordmarkImage())
        let data = try renderer.render(album: album, images: images, format: .story)

        XCTAssertFalse(data.range(of: Data("share-photo-".utf8)) != nil)
        let properties = try XCTUnwrap(imageProperties(for: data))
        let forbiddenKeys = ["{GPS}", "{IPTC}", "{MakerApple}", "Filename", "DateTimeOriginal", "Location"]
        for key in forbiddenKeys {
            XCTAssertNil(properties[key], "Unexpected private metadata key: \(key)")
        }
    }

    func testTemporaryArtifactCanBeSharedThenRemoved() throws {
        let data = Data(repeating: 0x41, count: 32)
        let url = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(data, format: .story)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertEqual(try Data(contentsOf: url), data)

        WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: url)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testPreparingAnotherFormatRemovesThePreviousTemporaryArtifact() throws {
        let storyURL = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(
            Data(repeating: 0x41, count: 32),
            format: .story
        )
        let postURL = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(
            Data(repeating: 0x42, count: 32),
            format: .post
        )
        defer { WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: postURL) }

        XCTAssertFalse(FileManager.default.fileExists(atPath: storyURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: postURL.path))
    }

    func testShareSheetAnalyticsGateEmitsOncePerPresentationAndResets() {
        var didCapture = false

        let first = ShareSheetAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            format: .story,
            entryPoint: .saveConfirmation
        )
        XCTAssertEqual(first?.name, "share_sheet_opened")
        XCTAssertNil(ShareSheetAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            format: .story,
            entryPoint: .saveConfirmation
        ))

        ShareSheetAnalyticsGate.reset(&didCapture)
        let second = ShareSheetAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            format: .post,
            entryPoint: .archiveDetail
        )
        XCTAssertEqual(second?.name, "share_sheet_opened")
        XCTAssertEqual(
            AnalyticsSchema.sanitizedProperties(for: second!),
            ["format": "post", "entry_point": "archive_detail"]
        )
    }

    func testNativeShareItemSourceUsesArtifactAndPrivacySafePreviewMetadata() throws {
        let previewData = makeWordmarkImage().jpegData(compressionQuality: 0.9)!
        let artifactURL = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(previewData, format: .story)
        defer { WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: artifactURL) }
        let source = WeeklyAlbumShareActivityItemSource(
            artifactURL: artifactURL,
            previewData: previewData,
            title: "Make this week yours to share"
        )
        let activityViewController = UIActivityViewController(
            activityItems: [artifactURL],
            applicationActivities: nil
        )

        XCTAssertEqual(source.activityViewControllerPlaceholderItem(activityViewController) as? URL, artifactURL)
        XCTAssertEqual(
            source.activityViewController(activityViewController, itemForActivityType: nil) as? URL,
            artifactURL
        )
        XCTAssertEqual(
            source.activityViewController(activityViewController, subjectForActivityType: nil),
            "Make this week yours to share"
        )
        XCTAssertNotNil(source.activityViewController(
            activityViewController,
            thumbnailImageForActivityType: nil,
            suggestedSize: CGSize(width: 120, height: 120)
        ))

        let metadata = try XCTUnwrap(source.activityViewControllerLinkMetadata(activityViewController))
        XCTAssertEqual(metadata.title, "Make this week yours to share")
        XCTAssertNil(metadata.originalURL)
        XCTAssertNil(metadata.url)
        XCTAssertNotNil(metadata.imageProvider)
    }

    private func makeAlbum(photoCount: Int) -> WeeklyAlbumSnapshot {
        let start = ISO8601DateFormatter().date(from: "2026-08-03T00:00:00+00:00")!
        let photos = (0..<photoCount).map { index in
            AlbumPhotoSnapshot(
                id: UUID(),
                assetLocalIdentifier: PhotoID("share-photo-\(index)"),
                capturedAt: start.addingTimeInterval(Double(index * 3_600)),
                position: index,
                source: .initial,
                scoreSnapshot: nil,
                isAvailable: true
            )
        }
        return WeeklyAlbumSnapshot(
            id: UUID(),
            weekKey: "2026-W32",
            kind: .regular,
            weekStart: start,
            weekEnd: start.addingTimeInterval(604_800),
            analysisCutoff: start.addingTimeInterval(604_800),
            createdAt: start,
            updatedAt: start,
            coverPhotoID: photos.first?.id,
            photos: photos
        )
    }

    private func makeImages(for album: WeeklyAlbumSnapshot) -> [PhotoID: PhotoImageData] {
        Dictionary(uniqueKeysWithValues: album.photos.enumerated().map { index, photo in
            let color = UIColor(hue: CGFloat(index) / 7, saturation: 0.28, brightness: 0.92, alpha: 1)
            let image = UIGraphicsImageRenderer(size: CGSize(width: 160, height: 220)).image { context in
                color.setFill()
                context.fill(CGRect(x: 0, y: 0, width: 160, height: 220))
            }
            return (
                photo.assetLocalIdentifier,
                PhotoImageData(data: image.jpegData(compressionQuality: 0.9)!, pixelWidth: 160, pixelHeight: 220)
            )
        })
    }

    private func makeWordmarkImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 420, height: 100)).image { context in
            UIColor(WeekkeepColors.plum).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 420, height: 100))
        }
    }

    private func imageSize(for data: Data) -> CGSize? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return CGSize(width: image.width, height: image.height)
    }

    private func imageProperties(for data: Data) -> [String: Any]? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else { return nil }
        return properties
    }
}
