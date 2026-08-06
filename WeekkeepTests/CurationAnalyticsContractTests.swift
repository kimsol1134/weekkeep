import Foundation
import XCTest
@testable import Weekkeep

final class CurationAnalyticsBucketContractTests: XCTestCase {
    func testCandidateCountBucketsCoverEveryBoundary() {
        let cases: [(Int, String)] = [
            (0, "0"),
            (1, "1-6"),
            (6, "1-6"),
            (7, "7-14"),
            (14, "7-14"),
            (15, "15-30"),
            (30, "15-30"),
            (31, "31-50"),
            (50, "31-50"),
            (51, "51-100"),
            (100, "51-100"),
            (101, "100+")
        ]

        for (count, expected) in cases {
            XCTAssertEqual(AnalyticsBucketContract.candidateCount(for: count), expected, "count: \(count)")
        }
    }

    func testDurationBucketsUseDocumentedHalfOpenBoundaries() {
        let cases: [(TimeInterval, String)] = [
            (0, "under_30s"),
            (29.999, "under_30s"),
            (30, "30_60s"),
            (59.999, "30_60s"),
            (60, "60_120s"),
            (119.999, "60_120s"),
            (120, "over_120s")
        ]

        for (duration, expected) in cases {
            XCTAssertEqual(AnalyticsBucketContract.duration(for: duration), expected, "duration: \(duration)")
        }
    }

    func testAnalyticsSchemaRejectsUnknownAndUnexpectedBucketValues() {
        XCTAssertFalse(
            AnalyticsSchema.validate(
                .curationStarted(albumKind: .welcome, candidateCountBucket: "unknown")
            )
        )
        XCTAssertFalse(
            AnalyticsSchema.validate(
                .curationStarted(albumKind: .welcome, candidateCountBucket: "6-7")
            )
        )
        XCTAssertFalse(
            AnalyticsSchema.validate(
                .curationCompleted(durationBucket: "foreground", selectedCount: 1)
            )
        )
        XCTAssertFalse(
            AnalyticsSchema.validate(
                .curationCompleted(durationBucket: "unknown", selectedCount: 1)
            )
        )
        XCTAssertFalse(
            AnalyticsSchema.validate(
                .albumSaved(
                    albumKind: .regular,
                    regularSequenceBucket: "w1",
                    selectedCount: 1,
                    replacementCount: 0,
                    activeReviewDurationBucket: "unexpected"
                )
            )
        )

        XCTAssertTrue(
            AnalyticsSchema.validate(
                .curationStarted(albumKind: .welcome, candidateCountBucket: "100+")
            )
        )
        XCTAssertTrue(
            AnalyticsSchema.validate(
                .curationCompleted(durationBucket: "over_120s", selectedCount: 7)
            )
        )
    }

    func testDictionarySanitizerStripsSDKExtrasFromValidCurationStartedEvent() throws {
        let sanitized = try XCTUnwrap(
            AnalyticsSchema.sanitizedProperties(
                eventName: "curation_started",
                properties: [
                    "album_kind": "regular",
                    "candidate_count_bucket": "7-14",
                    "$lib": "posthog-ios",
                    "$os": "iOS",
                    "photo_identifier": "must-not-leave-device"
                ]
            )
        )

        XCTAssertEqual(
            sanitized,
            [
                "album_kind": "regular",
                "candidate_count_bucket": "7-14"
            ]
        )
    }

    func testDictionarySanitizerRejectsInvalidApprovedProperties() {
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "curation_started",
                properties: [
                    "album_kind": "regular",
                    "candidate_count_bucket": "foreground"
                ]
            )
        )
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "curation_started",
                properties: [
                    "album_kind": "regular",
                    "candidate_count_bucket": "unknown"
                ]
            )
        )
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "curation_started",
                properties: [
                    "album_kind": 7,
                    "candidate_count_bucket": "7-14"
                ]
            )
        )
    }

    func testPrivacyDenylistStillRejectsPhotoLikeValues() {
        let event = AnalyticsEvent.curationStarted(
            albumKind: .regular,
            candidateCountBucket: "photo-local-id"
        )

        XCTAssertFalse(AnalyticsSchema.validate(event))
        XCTAssertFalse(AnalyticsSchema.isSafeValue("photo-local-id"))
    }
}

@MainActor
final class WeeklyCurationPartialSuccessTests: XCTestCase {
    func testPartialSuccessStateIsExplicitAndKeepsReviewSaveRouteAvailable() async throws {
        let analytics = RecordingAnalyticsClient()
        let suiteName = "weekkeep.curation.partial.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let library = FixturePhotoLibraryClient(
            descriptors: FixturePhotoLibraryClient.makeDescriptors(count: 1)
        )
        let environment = AppEnvironment(
            photoLibrary: library,
            analysisService: FixedDraftAnalysisService(skippedAssetCount: 2),
            albumStore: InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: analytics,
            defaults: defaults,
            isFixture: true
        )
        let model = WeeklyFlowModel(environment: environment)

        await model.refresh()
        model.startCuration()
        try await waitForRoute(.review, model: model)

        XCTAssertEqual(model.reviewState, .partialSuccess(skippedAssetCount: 2))
        XCTAssertTrue(model.reviewState.isPartialSuccess)
        XCTAssertEqual(model.reviewState.skippedAssetCount, 2)
        XCTAssertNotNil(model.draft)

        model.saveDraft()
        try await waitForRoute(.saveConfirmation, model: model)
        XCTAssertEqual(model.route, .saveConfirmation)
        XCTAssertNotNil(model.savedAlbum)
    }

    func testWelcomeRefreshStoresEligibleCountUsedByCurationStarted() async throws {
        let analytics = RecordingAnalyticsClient()
        let suiteName = "weekkeep.curation.count.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let library = FixturePhotoLibraryClient(
            descriptors: FixturePhotoLibraryClient.makeDescriptors(count: 6)
        )
        let environment = AppEnvironment(
            photoLibrary: library,
            analysisService: FixturePhotoAnalysisService(photoLibrary: library),
            albumStore: InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: analytics,
            defaults: defaults,
            isFixture: true
        )
        let model = WeeklyFlowModel(
            environment: environment,
            curationClock: SequenceCurationMonotonicClock(values: [0, 30_000_000_000])
        )

        await model.refresh()
        XCTAssertEqual(model.eligiblePhotoCountForCuration, 6)
        XCTAssertEqual(model.candidateCountBucketForCuration, "1-6")

        model.startCuration()
        try await waitForRoute(.review, model: model)
        try await Task.sleep(for: .milliseconds(20))

        let events = await analytics.events()
        let startedBucket = events.compactMap { event -> String? in
            guard case let .curationStarted(_, bucket) = event else { return nil }
            return bucket
        }.first
        let completedBucket = events.compactMap { event -> String? in
            guard case let .curationCompleted(bucket, _) = event else { return nil }
            return bucket
        }.first

        XCTAssertEqual(startedBucket, "1-6")
        XCTAssertEqual(completedBucket, "30_60s")
        XCTAssertFalse(events.contains { $0.properties.values.contains("unknown") || $0.properties.values.contains("foreground") })
    }

    func testPartialReviewHasStableAccessibleMessageIdentifier() {
        XCTAssertEqual(
            WeeklyReviewView.partialSuccessAccessibilityIdentifier,
            "SCR-WK-03-PartialSuccess"
        )
        XCTAssertEqual(CurationReviewState.afterAnalysis(skippedAssetCount: 0), .ready)
        XCTAssertEqual(CurationReviewState.afterAnalysis(skippedAssetCount: 3), .partialSuccess(skippedAssetCount: 3))
    }

    private func waitForRoute(
        _ expected: WeeklyRoute,
        model: WeeklyFlowModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        for _ in 0..<100 {
            if model.route == expected { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTFail("Timed out waiting for route \(expected)", file: file, line: line)
    }
}

private actor RecordingAnalyticsClient: AnalyticsClient {
    private var capturedEvents: [AnalyticsEvent] = []

    func capture(_ event: AnalyticsEvent) async {
        capturedEvents.append(event)
    }

    func flush() async {}

    func events() -> [AnalyticsEvent] {
        capturedEvents
    }
}

private actor FixedDraftAnalysisService: PhotoAnalysisService {
    let skippedAssetCount: Int

    init(skippedAssetCount: Int) {
        self.skippedAssetCount = skippedAssetCount
    }

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft {
        progress(CurationProgress(stage: .ranking, completed: 1, total: 1, skippedCount: skippedAssetCount))
        let photo = PhotoReference(
            id: PhotoID("partial-selected"),
            capturedAt: week.start.addingTimeInterval(3_600),
            pixelWidth: 1_200,
            pixelHeight: 1_600,
            score: 0.8,
            source: .initial
        )
        return try CurationDraft(
            id: UUID(),
            kind: kind,
            week: week,
            analysisCutoff: analysisCutoff,
            selected: [photo],
            alternatives: [],
            replacementCount: 0,
            skippedAssetCount: skippedAssetCount
        ).validated()
    }
}

private final class SequenceCurationMonotonicClock: CurationMonotonicClock, @unchecked Sendable {
    private var values: [UInt64]
    private var index = 0

    init(values: [UInt64]) {
        self.values = values
    }

    func nowNanoseconds() -> UInt64 {
        defer { index += 1 }
        return values[min(index, values.count - 1)]
    }
}
