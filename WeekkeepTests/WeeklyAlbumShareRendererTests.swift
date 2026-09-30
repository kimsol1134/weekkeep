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
        XCTAssertFalse(data.range(of: Data(WeeklyAlbumShareContract.canonicalInstallURL.absoluteString.utf8)) != nil)
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

    func testCumulativeSavedWeekOrdinalIncludesWelcomeAndUsesStableTieBreakers() {
        let welcomeID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let earlierRegularID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let targetID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let laterID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        let firstDate = Date(timeIntervalSince1970: 1_700_000_000)
        let secondDate = firstDate.addingTimeInterval(86_400)

        let summaries = [
            makeSummary(id: targetID, kind: .regular, createdAt: secondDate, weekStart: secondDate),
            makeSummary(id: laterID, kind: .regular, createdAt: secondDate.addingTimeInterval(1), weekStart: secondDate),
            makeSummary(id: welcomeID, kind: .welcome, createdAt: firstDate, weekStart: firstDate),
            makeSummary(id: earlierRegularID, kind: .regular, createdAt: secondDate, weekStart: firstDate)
        ]

        XCTAssertEqual(WeeklyAlbumShareOrdinal.ordinal(for: targetID, in: summaries), 3)
        XCTAssertEqual(WeeklyAlbumShareOrdinal.ordinal(for: welcomeID, in: summaries), 1)
    }

    func testSavedWeekOrdinalIsNilWhenAlbumIsAbsentAndRetainedWhenAlbumIsEdited() {
        let targetID = UUID(uuidString: "00000000-0000-0000-0000-000000000012")!
        let otherID = UUID(uuidString: "00000000-0000-0000-0000-000000000013")!
        let createdAt = Date(timeIntervalSince1970: 1_700_100_000)
        let summaries = [
            makeSummary(id: otherID, kind: .welcome, createdAt: createdAt.addingTimeInterval(-1), weekStart: createdAt.addingTimeInterval(-1)),
            makeSummary(id: targetID, kind: .regular, createdAt: createdAt, weekStart: createdAt)
        ]
        let editedSummaries = [
            makeSummary(id: otherID, kind: .welcome, createdAt: createdAt.addingTimeInterval(-1), weekStart: createdAt.addingTimeInterval(-1)),
            makeSummary(id: targetID, kind: .regular, createdAt: createdAt, weekStart: createdAt.addingTimeInterval(604_800))
        ]

        XCTAssertEqual(WeeklyAlbumShareOrdinal.ordinal(for: targetID, in: summaries), 2)
        XCTAssertEqual(WeeklyAlbumShareOrdinal.ordinal(for: targetID, in: editedSummaries), 2)
        XCTAssertNil(WeeklyAlbumShareOrdinal.ordinal(for: UUID(), in: summaries))
    }

    func testShareIdentitySerialLabelIsLocalizedAndOmitsInvalidOrdinal() {
        let identity = WeeklyAlbumShareIdentity(ordinal: 12)
        XCTAssertEqual(
            identity.serialLabel(locale: Locale(identifier: "en_US")),
            "Our family · week 12"
        )
        XCTAssertEqual(
            identity.serialLabel(locale: Locale(identifier: "ko_KR")),
            "우리 가족의 12번째 주"
        )
        XCTAssertEqual(
            WeekkeepLocalization.string("share.footerPrompt", locale: Locale(identifier: "en_US")),
            "How was your family's week?"
        )
        XCTAssertEqual(
            WeekkeepLocalization.string("share.footerPrompt", locale: Locale(identifier: "ko_KR")),
            "너희 가족의 이번 주는 어땠어?"
        )
        XCTAssertNil(WeeklyAlbumShareIdentity(ordinal: nil).serialLabel(locale: Locale(identifier: "en_US")))
        XCTAssertNil(WeeklyAlbumShareIdentity(ordinal: 0).serialLabel(locale: Locale(identifier: "ko_KR")))
    }

    func testShareCompletionAnalyticsGateRecordsSuccessfulCompletionOnceAndIgnoresCancellation() {
        var didCapture = false

        XCTAssertNil(ShareCompletionAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            completed: false,
            format: .story,
            entryPoint: .saveConfirmation
        ))
        XCTAssertFalse(didCapture)

        let completed = ShareCompletionAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            completed: true,
            format: .story,
            entryPoint: .saveConfirmation
        )
        XCTAssertEqual(completed?.name, "share_completed")
        XCTAssertEqual(
            AnalyticsSchema.sanitizedProperties(for: completed!),
            ["format": "story", "entry_point": "save_confirmation"]
        )
        XCTAssertNil(ShareCompletionAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            completed: true,
            format: .post,
            entryPoint: .archiveDetail
        ))

        ShareCompletionAnalyticsGate.reset(&didCapture)
        let secondPresentation = ShareCompletionAnalyticsGate.eventIfNeeded(
            didCapture: &didCapture,
            completed: true,
            format: .post,
            entryPoint: .archiveDetail
        )
        XCTAssertEqual(secondPresentation?.name, "share_completed")
        XCTAssertEqual(secondPresentation?.properties.keys.sorted(), ["entry_point", "format"])
    }

    func testCompletionHandlerDoesNotRepresentDestinationActivityTypeReturnedItemsOrError() {
        var completions: [Bool] = []
        let handler = NativeShareSheet.completionHandler { completed in
            completions.append(completed)
        }

        handler(
            UIActivity.ActivityType(rawValue: "private.destination"),
            true,
            ["private recipient and message"],
            NSError(domain: "private.destination", code: 1)
        )
        handler(
            UIActivity.ActivityType(rawValue: "another.destination"),
            false,
            ["returned item"],
            NSError(domain: "another.destination", code: 2)
        )

        XCTAssertEqual(completions, [true, false])
        let completed = AnalyticsEvent.shareCompleted(format: .post, entryPoint: .archiveDetail)
        XCTAssertEqual(completed.properties.keys.sorted(), ["entry_point", "format"])
        XCTAssertEqual(AnalyticsSchema.allowedPropertyKeys[completed.name], ["format", "entry_point"])
        XCTAssertEqual(
            AnalyticsSchema.sanitizedProperties(
                eventName: completed.name,
                properties: [
                    "format": "post",
                    "entry_point": "archive_detail",
                    "destination": "private.destination",
                    "activity_type": "another.destination",
                    "returned_items": "private recipient",
                    "error": "private error",
                    "recipient": "private recipient",
                    "message": "private message"
                ]
            ),
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
            activityItems: [],
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

    func testShareContractUsesCanonicalAppleURLAndLocalizedParentInvitation() {
        XCTAssertEqual(WeeklyAlbumShareContract.appStoreAppID, "6798449478")
        XCTAssertEqual(
            WeeklyAlbumShareContract.canonicalInstallURL.absoluteString,
            "https://apps.apple.com/app/id6798449478"
        )
        XCTAssertEqual(WeeklyAlbumShareContract.canonicalInstallURL.scheme, "https")
        XCTAssertEqual(WeeklyAlbumShareContract.canonicalInstallURL.host, "apps.apple.com")
        XCTAssertFalse(WeeklyAlbumShareContract.canonicalInstallURL.absoluteString.contains("chatgpt.site"))

        XCTAssertEqual(
            WeeklyAlbumShareContract.localizedInvitation(locale: Locale(identifier: "en_US")),
            "A week with our family 🌈\nMade with Weekkeep.\nHow was your family's week?"
        )
        XCTAssertEqual(
            WeeklyAlbumShareContract.localizedInvitation(locale: Locale(identifier: "ko_KR")),
            "우리 가족의 일주일 🌈\nWeekkeep으로 남겼어요.\n너희 가족의 이번 주는 어땠어?"
        )
    }

    func testNativeShareCompositionKeepsImagePrimaryAndAddsTextAndURLItems() throws {
        let previewData = makeWordmarkImage().jpegData(compressionQuality: 0.9)!
        let artifactURL = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(previewData, format: .story)
        defer { WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: artifactURL) }

        let invitation = WeeklyAlbumShareContract.localizedInvitation(locale: Locale(identifier: "en_US"))
        let payload = WeeklyAlbumShareActivityItems(
            artifactURL: artifactURL,
            previewData: previewData,
            title: "A small album to share",
            locale: Locale(identifier: "en_US")
        )
        let activityViewController = UIActivityViewController(
            activityItems: [],
            applicationActivities: nil
        )

        XCTAssertEqual(payload.activityItems.count, 3)
        XCTAssertTrue((payload.activityItems[0] as AnyObject) === payload.imageSource)
        XCTAssertTrue((payload.activityItems[1] as AnyObject) === payload.invitationSource)
        XCTAssertTrue((payload.activityItems[2] as AnyObject) === payload.installURLSource)
        XCTAssertEqual(payload.imageSource.artifactURL, artifactURL)
        XCTAssertEqual(payload.invitationSource.invitation, invitation)
        XCTAssertEqual(payload.installURLSource.url, WeeklyAlbumShareContract.canonicalInstallURL)

        XCTAssertEqual(
            payload.imageSource.activityViewController(
                activityViewController,
                itemForActivityType: nil
            ) as? URL,
            artifactURL,
            "Image-only destinations must retain the local artifact item."
        )
        XCTAssertEqual(
            payload.invitationSource.activityViewController(
                activityViewController,
                itemForActivityType: nil
            ) as? String,
            invitation
        )
        XCTAssertEqual(
            payload.installURLSource.activityViewController(
                activityViewController,
                itemForActivityType: nil
            ) as? URL,
            WeeklyAlbumShareContract.canonicalInstallURL
        )

        let linkMetadata = try XCTUnwrap(
            payload.installURLSource.activityViewControllerLinkMetadata(activityViewController)
        )
        XCTAssertEqual(linkMetadata.originalURL, WeeklyAlbumShareContract.canonicalInstallURL)
        XCTAssertEqual(linkMetadata.url, WeeklyAlbumShareContract.canonicalInstallURL)
    }

    func testNativeSharePayloadCannotBeConfiguredWithAnArbitraryInstallURLOrInvitation() throws {
        let previewData = makeWordmarkImage().jpegData(compressionQuality: 0.9)!
        let artifactURL = try WeeklyAlbumShareFileStore.writeTemporaryArtifact(previewData, format: .story)
        defer { WeeklyAlbumShareFileStore.removeTemporaryArtifact(at: artifactURL) }

        let payload = WeeklyAlbumShareActivityItems(
            artifactURL: artifactURL,
            previewData: previewData,
            title: "A small album to share",
            locale: Locale(identifier: "ko_KR")
        )

        XCTAssertEqual(
            payload.installURLSource.url,
            WeeklyAlbumShareContract.canonicalInstallURL,
            "The native share payload must use only the configured Apple App Store URL."
        )
        XCTAssertEqual(
            payload.invitationSource.invitation,
            WeeklyAlbumShareContract.localizedInvitation(locale: Locale(identifier: "ko_KR")),
            "The native share payload must use the localized product invitation."
        )
    }

    func testShareImplementationHasNoThirdPartyDestinationOrUploadDependency() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let shareSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("Weekkeep/Features/Sharing/WeeklyAlbumShare.swift"),
            encoding: .utf8
        )
        let projectSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("project.yml"),
            encoding: .utf8
        )

        XCTAssertTrue(shareSource.contains("UIActivityViewController"))
        XCTAssertTrue(shareSource.contains("applicationActivities: nil"))
        XCTAssertTrue(shareSource.contains("[imageSource, invitationSource, installURLSource]"))
        XCTAssertFalse(shareSource.contains("installURL:"))
        XCTAssertFalse(shareSource.contains("init(url:"))
        XCTAssertFalse(shareSource.localizedCaseInsensitiveContains("kakao"))
        XCTAssertFalse(shareSource.localizedCaseInsensitiveContains("instagram"))
        XCTAssertFalse(shareSource.localizedCaseInsensitiveContains("upload"))
        XCTAssertFalse(projectSource.localizedCaseInsensitiveContains("kakao"))
        XCTAssertFalse(projectSource.localizedCaseInsensitiveContains("instagram"))
    }

    func testPhysicalShareQAHarnessIsOptInFixtureOnlyAndNeverSelectsDestination() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let uiTestSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent("WeekkeepUITests/WeekkeepUITests.swift"),
            encoding: .utf8
        )
        let harnessStart = try XCTUnwrap(
            uiTestSource.range(of: "func testPhysicalShareSheetQAIsOptInFixtureOnlyNoPrivatePixelsNoSend()")
        )
        let harnessEnd = try XCTUnwrap(
            uiTestSource.range(
                of: "\n    func testReplacementStartsWithSameDayAndDisclosesOtherDays()",
                range: harnessStart.upperBound..<uiTestSource.endIndex
            )
        )
        let harnessSource = String(uiTestSource[harnessStart.lowerBound..<harnessEnd.lowerBound])

        XCTAssertTrue(uiTestSource.contains("WK_CAPTURE_PHYSICAL_SHARE_QA"))
        XCTAssertTrue(uiTestSource.contains("throw XCTSkip(\"Physical native share-sheet QA is opt-in.\")"))
        XCTAssertTrue(uiTestSource.contains("WK_PHYSICAL_SHARE_QA_LOCALE"))
        XCTAssertTrue(uiTestSource.contains("static let defaultLocale = \"ko\""))
        XCTAssertTrue(uiTestSource.contains("app.launchArguments = [\"-ui-fixtures\"]"))
        XCTAssertTrue(uiTestSource.contains("WK_UI_TEST_FIXTURES"))
        XCTAssertTrue(uiTestSource.contains("app.sheets.element(boundBy: existingAppSheetCount)"))
        XCTAssertTrue(uiTestSource.contains("com.apple.UIKit.activity"))
        XCTAssertTrue(uiTestSource.contains("com.apple.springboard"))
        XCTAssertTrue(uiTestSource.contains("UIActivityContentView"))
        XCTAssertTrue(uiTestSource.contains("attachment.lifetime = .keepAlways"))
        XCTAssertTrue(harnessSource.contains("launchFixture(language: language, screen: \"ready\")"))
        XCTAssertTrue(harnessSource.contains("SHEET-SHARE-01-Preview"))
        XCTAssertTrue(harnessSource.contains("physical-share-qa-before-native-share-sheet"))
        XCTAssertTrue(harnessSource.contains("physical-share-qa-after-native-share-sheet"))
        XCTAssertTrue(harnessSource.contains("waitForNativeShareAccessibilityPresentation"))
        XCTAssertTrue(harnessSource.contains("app.terminate()"))
        XCTAssertEqual(harnessSource.components(separatedBy: "shareButton.tap()").count - 1, 1)
        XCTAssertEqual(harnessSource.components(separatedBy: ".tap()").count - 1, 4)
        XCTAssertFalse(harnessSource.localizedCaseInsensitiveContains("kakaotalk"))
        XCTAssertFalse(harnessSource.localizedCaseInsensitiveContains("instagram"))
        XCTAssertFalse(harnessSource.contains("UIActivity.ActivityType"))
        XCTAssertFalse(harnessSource.contains("systemShare"))
        XCTAssertFalse(harnessSource.contains("destination.tap"))
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

    private func makeSummary(
        id: UUID,
        kind: AlbumKind,
        createdAt: Date,
        weekStart: Date
    ) -> WeeklyAlbumSummary {
        WeeklyAlbumSummary(
            id: id,
            weekKey: "summary-\(id.uuidString)",
            kind: kind,
            weekStart: weekStart,
            weekEnd: weekStart.addingTimeInterval(604_800),
            createdAt: createdAt,
            photoCount: 1,
            availablePhotoCount: 1,
            coverPhotoID: nil
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
