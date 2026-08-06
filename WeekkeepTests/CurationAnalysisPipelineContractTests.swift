import Foundation
import UIKit
import XCTest
@testable import Weekkeep

final class CurationAnalysisPipelineContractTests: XCTestCase {
    func testOneHundredEligibleDescriptorsProduceAtMostTwentyOneVisionCalls() async throws {
        let (week, descriptors) = makeWeekAndDescriptors(count: 100)
        let library = PipelinePhotoLibrary(descriptors: descriptors)
        let analyzer = CountingPhotoSignalAnalyzer()
        let progress = LockedCurationProgressRecorder()
        let budget = CurationAnalysisBudget(
            descriptorScanLimit: 500,
            maximumVisionCandidates: 21,
            analysisPixelSize: 416,
            perAssetTimeoutNanoseconds: 500_000_000,
            globalTimeoutNanoseconds: 5_000_000_000
        )
        let pipeline = OnDevicePhotoAnalysisPipeline(
            photoLibrary: library,
            analyzer: analyzer,
            budget: budget,
            timeZoneIdentifier: "UTC"
        )

        let draft = try await pipeline.makeDraft(
            kind: .regular,
            week: week,
            analysisCutoff: week.cutoff,
            progress: progress.append
        )

        let analyzerCallCount = await analyzer.callCount()
        let sessionCount = await analyzer.sessionCount()
        let analysisRequests = await library.analysisRequests()
        XCTAssertFalse(draft.selected.isEmpty)
        XCTAssertEqual(sessionCount, 1)
        XCTAssertLessThanOrEqual(analyzerCallCount, 21)
        XCTAssertEqual(analyzerCallCount, analysisRequests.count)
        XCTAssertTrue(analysisRequests.allSatisfy { request in
            request.targetSize == CGSize(width: 416, height: 416)
        })
        assertProgressIsMonotonic(progress.snapshot(), expectedTotal: 21)
    }

    func testGlobalBudgetReturnsARealPartialDraftAndMarksRemainingWorkSkipped() async throws {
        let (week, descriptors) = makeWeekAndDescriptors(count: 100)
        let library = PipelinePhotoLibrary(descriptors: descriptors)
        let analyzer = CountingPhotoSignalAnalyzer()
        let progress = LockedCurationProgressRecorder()
        let clock = SequencePhotoAnalysisClock(values: [0, 0, 0, 1_000_000])
        let budget = CurationAnalysisBudget(
            descriptorScanLimit: 500,
            maximumVisionCandidates: 21,
            analysisPixelSize: 416,
            perAssetTimeoutNanoseconds: 10_000_000,
            globalTimeoutNanoseconds: 1_000_000
        )
        let pipeline = OnDevicePhotoAnalysisPipeline(
            photoLibrary: library,
            analyzer: analyzer,
            budget: budget,
            clock: clock,
            timeZoneIdentifier: "UTC"
        )

        let draft = try await pipeline.makeDraft(
            kind: .regular,
            week: week,
            analysisCutoff: week.cutoff,
            progress: progress.append
        )

        let analyzerCallCount = await analyzer.callCount()
        XCTAssertFalse(draft.selected.isEmpty)
        XCTAssertGreaterThan(draft.skippedAssetCount, 0)
        XCTAssertLessThan(analyzerCallCount, 21)
        let final = try XCTUnwrap(progress.snapshot().last)
        XCTAssertEqual(final.overallCompleted, final.overallTotal)
        XCTAssertEqual(final.overallTotal, 21)
        assertProgressIsMonotonic(progress.snapshot(), expectedTotal: 21)
    }

    func testPerAssetTimeoutKeepsFastPhotosAndDoesNotWaitForSlowAssets() async throws {
        let (week, descriptors) = makeWeekAndDescriptors(count: 10)
        let slowIDs = Set(descriptors.dropFirst().map(\.id))
        let library = PipelinePhotoLibrary(
            descriptors: descriptors,
            delays: Dictionary(uniqueKeysWithValues: slowIDs.map { ($0, 20_000_000) })
        )
        let analyzer = CountingPhotoSignalAnalyzer()
        let budget = CurationAnalysisBudget(
            descriptorScanLimit: 500,
            maximumVisionCandidates: 21,
            analysisPixelSize: 416,
            perAssetTimeoutNanoseconds: 1_000_000,
            globalTimeoutNanoseconds: 100_000_000
        )
        let pipeline = OnDevicePhotoAnalysisPipeline(
            photoLibrary: library,
            analyzer: analyzer,
            budget: budget,
            timeZoneIdentifier: "UTC"
        )

        let draft = try await pipeline.makeDraft(
            kind: .regular,
            week: week,
            analysisCutoff: week.cutoff,
            progress: { _ in }
        )

        let analyzerCallCount = await analyzer.callCount()
        XCTAssertEqual(analyzerCallCount, 1)
        XCTAssertEqual(draft.selected.count, 1)
        XCTAssertGreaterThan(draft.skippedAssetCount, 0)
    }

    private func makeWeekAndDescriptors(count: Int) -> (WeekRange, [PhotoDescriptor]) {
        let start = ISO8601DateFormatter().date(from: "2026-08-03T00:00:00+00:00")!
        let descriptors = (0..<count).map { index in
            PhotoDescriptor(
                id: PhotoID("pipeline-\(index)"),
                capturedAt: start.addingTimeInterval(Double(index * 3_600)),
                pixelWidth: 1_200,
                pixelHeight: 1_600,
                isFavorite: index == 0,
                isHidden: false,
                isScreenshot: false
            )
        }
        let week = WeekRange(
            key: "2026-W32",
            start: start,
            end: start.addingTimeInterval(604_800),
            cutoff: start.addingTimeInterval(604_800),
            eligibleFrom: nil,
            eligibleUntil: nil,
            kind: .regular
        )
        return (week, descriptors)
    }

    private func assertProgressIsMonotonic(
        _ updates: [CurationProgress],
        expectedTotal: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertFalse(updates.isEmpty, file: file, line: line)
        XCTAssertEqual(updates.last?.overallTotal, expectedTotal, file: file, line: line)
        for pair in zip(updates, updates.dropFirst()) {
            XCTAssertLessThanOrEqual(pair.0.overallCompleted, pair.1.overallCompleted, file: file, line: line)
        }
    }
}

private actor PipelinePhotoLibrary: PhotoLibraryClient {
    private let descriptors: [PhotoDescriptor]
    private let delays: [PhotoID: UInt64]
    private var requests: [(id: PhotoID, targetSize: CGSize)] = []

    init(descriptors: [PhotoDescriptor], delays: [PhotoID: UInt64] = [:]) {
        self.descriptors = descriptors
        self.delays = delays
    }

    func authorizationStatus() async -> PhotoAuthorization { .authorized }

    func requestAuthorization() async -> PhotoAuthorization { .authorized }

    func fetchDescriptors(in range: DateInterval, limit: Int) async throws -> [PhotoDescriptor] {
        Array(descriptors.filter { range.contains($0.capturedAt) }.prefix(limit))
    }

    func analysisImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        requests.append((id: id, targetSize: targetSize))
        if let delay = delays[id] {
            try await Task.sleep(nanoseconds: delay)
        }
        try Task.checkCancellation()
        return PhotoImageData(data: Data([0x01, 0x02, 0x03]), pixelWidth: Int(targetSize.width), pixelHeight: Int(targetSize.height))
    }

    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        try await analysisImage(for: id, targetSize: targetSize)
    }

    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID> {
        Set(ids.filter { id in descriptors.contains { $0.id == id } })
    }

    func analysisRequests() -> [(id: PhotoID, targetSize: CGSize)] { requests }
}

private actor CountingPhotoSignalAnalyzer: PhotoSignalAnalyzer {
    private var calls = 0
    private var sessions = 0

    func beginAnalysisSession() async {
        sessions += 1
    }

    func analyze(imageData: Data, photoID: PhotoID) async throws -> VisionSignals {
        _ = imageData
        _ = photoID
        calls += 1
        return VisionSignals(
            aestheticsScore: 0.82,
            isUtility: false,
            technicalScore: 0.88,
            faceCompositionScore: 0.72,
            duplicateGroup: nil
        )
    }

    func callCount() -> Int { calls }

    func sessionCount() -> Int { sessions }
}

private final class LockedCurationProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var updates: [CurationProgress] = []

    func append(_ update: CurationProgress) {
        lock.lock()
        updates.append(update)
        lock.unlock()
    }

    func snapshot() -> [CurationProgress] {
        lock.lock()
        defer { lock.unlock() }
        return updates
    }
}

private final class SequencePhotoAnalysisClock: PhotoAnalysisClock, @unchecked Sendable {
    private let lock = NSLock()
    private var values: [UInt64]
    private var index = 0

    init(values: [UInt64]) {
        self.values = values
    }

    func nowNanoseconds() -> UInt64 {
        lock.lock()
        defer { lock.unlock() }
        let value = values[min(index, values.count - 1)]
        index += 1
        return value
    }
}
