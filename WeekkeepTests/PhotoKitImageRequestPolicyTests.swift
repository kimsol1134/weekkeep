import UIKit
import XCTest
@testable import Weekkeep

final class PhotoKitImageRequestPolicyTests: XCTestCase {
    func testFastFormatCompletesOnTheFirstUsableImageIncludingDegraded() {
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: true,
                degraded: true,
                deliveryMode: .fastFormat
            ),
            .complete(cancelOutstanding: true)
        )
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: true,
                degraded: false,
                deliveryMode: .fastFormat
            ),
            .complete(cancelOutstanding: true)
        )
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: false,
                degraded: false,
                deliveryMode: .fastFormat
            ),
            .fail
        )
    }

    func testOpportunisticDisplayKeepsADegradedFrameAsFallbackInsteadOfHanging() {
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: true,
                degraded: true,
                deliveryMode: .opportunisticHighQuality
            ),
            .usePartial
        )
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: true,
                degraded: false,
                deliveryMode: .opportunisticHighQuality
            ),
            .complete(cancelOutstanding: false)
        )
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: false,
                degraded: true,
                deliveryMode: .opportunisticHighQuality
            ),
            .ignore
        )
        XCTAssertEqual(
            PhotoKitImageRequestPolicy.decision(
                hasImage: false,
                degraded: false,
                deliveryMode: .opportunisticHighQuality
            ),
            .fail
        )
    }

    func testAnalysisSizedFrameFillsAStripButStillNeedsAHeroDownload() {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: CGSize(width: 416, height: 416), format: format).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 416, height: 416))
        }
        let frame = PhotoDisplayFrame(image: image)
        XCTAssertTrue(frame.meets(PhotoDisplayTarget.strip))
        XCTAssertFalse(frame.meets(PhotoDisplayTarget.hero))
        XCTAssertFalse(frame.meets(PhotoDisplayTarget.reviewTile))
    }

    func testDisplayGateLetsAHeroJumpAheadOfQueuedVisibleRequests() async {
        let gate = PhotoDisplayRequestGate(limit: 1)
        let first = await gate.acquire(priority: .visible)
        XCTAssertTrue(first)

        let visibleWaiter = Task { await gate.acquire(priority: .visible) }
        try? await Task.sleep(nanoseconds: 20_000_000)
        let heroWaiter = Task { await gate.acquire(priority: .hero) }
        try? await Task.sleep(nanoseconds: 20_000_000)

        await gate.release()
        let heroGranted = await heroWaiter.value
        XCTAssertTrue(heroGranted)
        await gate.release()
        let visibleGranted = await visibleWaiter.value
        XCTAssertTrue(visibleGranted)
    }

    func testJPEGEncoderProducesNonemptyDataForAnOpaqueImage() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 4, height: 4)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 4))
        }
        let data = try XCTUnwrap(PhotoKitJPEGEncoder.data(from: image))
        XCTAssertFalse(data.isEmpty)
        XCTAssertNotNil(UIImage(data: data))
    }

    func testReviewTilesReuseCachedFramesAndCapICloudDownloads() throws {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let thumbnailSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/DesignSystem/Components/PhotoComponents.swift"
            ),
            encoding: .utf8
        )
        let clientSource = try String(
            contentsOf: repositoryRoot.appendingPathComponent(
                "Weekkeep/Data/Photos/PhotoLibraryClient.swift"
            ),
            encoding: .utf8
        )

        XCTAssertTrue(thumbnailSource.contains("cachedDisplayFrame"))
        XCTAssertTrue(thumbnailSource.contains("displayFrames"))
        XCTAssertTrue(thumbnailSource.contains("priority"))
        XCTAssertFalse(thumbnailSource.contains("analysisImage"))
        XCTAssertTrue(clientSource.contains("rememberDisplayFrame"))
        XCTAssertTrue(clientSource.contains("displayGate.withPermit"))
        XCTAssertTrue(clientSource.contains("PhotoDisplayRequestGate"))
    }
}
