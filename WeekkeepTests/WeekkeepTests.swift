import Foundation
import XCTest
@testable import Weekkeep

final class WeekRangeCalculatorTests: XCTestCase {
    private let seoul = TimeZone(identifier: "Asia/Seoul")!

    func testMondayToSundayAndCompletionWindow() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let now = date("2026-08-10T20:30:00+09:00")
        let cycle = date("2026-07-27T00:00:00+09:00")

        let target = calculator.latestEligibleRegular(now: now, regularCycleStartsAt: cycle)

        XCTAssertEqual(target?.key, "2026-W32")
        XCTAssertEqual(target?.start, date("2026-08-03T00:00:00+09:00"))
        XCTAssertEqual(target?.end, date("2026-08-10T00:00:00+09:00"))
        XCTAssertEqual(target?.eligibleUntil, date("2026-08-17T00:00:00+09:00"))
    }

    func testMissedWeekReturnsOnlyLatestCompletedWeek() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let now = date("2026-08-24T12:00:00+09:00")
        let cycle = date("2026-07-27T00:00:00+09:00")

        let target = calculator.latestCompletedRegular(now: now, regularCycleStartsAt: cycle)

        XCTAssertEqual(target?.key, "2026-W34")
        XCTAssertEqual(target?.start, date("2026-08-17T00:00:00+09:00"))
    }

    func testWelcomeCycleStartsOnNextMonday() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let savedAt = date("2026-08-05T18:00:00+09:00")
        XCTAssertEqual(calculator.regularCycleStart(forWelcomeSavedAt: savedAt), date("2026-08-10T00:00:00+09:00"))
    }

    func testYearBoundaryUsesISOWeekYear() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let start = date("2027-01-04T00:00:00+09:00")
        XCTAssertEqual(calculator.weekKey(for: start), "2027-W01")
    }

    func testPreferredFirstAlbumRangeUsesMostRecentlyCompletedLocalISOWeek() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let now = date("2026-08-05T12:00:00+09:00")

        let range = calculator.preferredFirstAlbumRange(now: now)

        XCTAssertEqual(range.key, "welcome-completed-2026-W31")
        XCTAssertEqual(range.start, date("2026-07-27T00:00:00+09:00"))
        XCTAssertEqual(range.end, date("2026-08-03T00:00:00+09:00"))
        XCTAssertEqual(range.welcomeAlbumRangeStrategy, .completedCalendarWeek)
    }

    func testRollingFallbackIsSelectedOnlyWhenCompletedWeekHasNoEligiblePhotos() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let now = date("2026-08-05T12:00:00+09:00")

        let fallback = calculator.selectFirstAlbumRange(
            now: now,
            preferredEligiblePhotoCount: 0,
            fallbackEligiblePhotoCount: 3
        )
        XCTAssertEqual(fallback?.strategy, .rollingSevenDayFallback)
        XCTAssertEqual(fallback?.range.key, "welcome-rolling-2026-08-05")

        let preferred = calculator.selectFirstAlbumRange(
            now: now,
            preferredEligiblePhotoCount: 2,
            fallbackEligiblePhotoCount: 3
        )
        XCTAssertEqual(preferred?.strategy, .completedCalendarWeek)
        XCTAssertNil(calculator.selectFirstAlbumRange(
            now: now,
            preferredEligiblePhotoCount: 0,
            fallbackEligiblePhotoCount: 0
        ))
    }

    func testRollingFirstAlbumRangeUsesCalendarDaysAcrossDST() {
        let pacific = TimeZone(identifier: "America/Los_Angeles")!
        let calculator = WeekRangeCalculator(timeZone: pacific)
        let analysisStartedAt = date("2026-03-09T12:00:00-07:00")

        let range = calculator.rollingFirstAlbumRange(analysisStartedAt: analysisStartedAt)

        XCTAssertEqual(range.start, date("2026-03-02T12:00:00-08:00"))
        XCTAssertEqual(range.end, analysisStartedAt)
        XCTAssertEqual(range.key, "welcome-rolling-2026-03-09")
    }

    func testPreferredFirstAlbumNextEligibilityIsOneToSevenLocalDaysAfterActivation() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = seoul
        let monday = date("2026-08-03T12:00:00+09:00")
        let preferred = calculator.preferredFirstAlbumRange(now: monday)
        let nextEligible = try! XCTUnwrap(
            calculator.regularRange(startingAt: preferred.end).eligibleFrom
        )

        for offset in 0..<7 {
            let activation = calendar.date(byAdding: .day, value: offset, to: monday)!
            let activationDay = calendar.startOfDay(for: activation)
            let eligibilityDay = calendar.startOfDay(for: nextEligible)
            let dayDifference = calendar.dateComponents([.day], from: activationDay, to: eligibilityDay).day!
            XCTAssertTrue(
                (1...7).contains(dayDifference),
                "Unexpected day difference \(dayDifference) for \(activation)"
            )
        }
        XCTAssertEqual(nextEligible, date("2026-08-10T00:00:00+09:00"))
    }

    func testLegacyRollingWelcomeKeepsNextMondayCycleCompatibility() {
        let calculator = WeekRangeCalculator(timeZone: seoul)
        let savedAt = date("2026-08-05T18:00:00+09:00")
        let legacy = calculator.welcomeRange(analysisStartedAt: savedAt)

        XCTAssertEqual(legacy.welcomeAlbumRangeStrategy, .legacyRollingWelcome)
        XCTAssertEqual(
            calculator.regularCycleStart(forWelcomeRange: legacy, savedAt: savedAt),
            date("2026-08-10T00:00:00+09:00")
        )
        let preferred = calculator.preferredFirstAlbumRange(now: savedAt)
        XCTAssertEqual(
            calculator.regularCycleStart(forWelcomeRange: preferred, savedAt: savedAt),
            preferred.end
        )
    }

    private func date(_ string: String) -> Date {
        ISO8601DateFormatter().date(from: string)!
    }
}

final class WeekRootStateReducerTests: XCTestCase {
    private let reducer = WeekRootStateReducer()

    func testPermissionTakesPriorityOverEverything() {
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.denied),
            localState: .loading,
            eligiblePhotoCount: .loaded(42),
            creationAccess: .loaded(.inactive)
        )
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .permissionBlocked(.denied))
    }

    func testLimitedAccessWithNoPhotosIsHonestEmptyState() {
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.limited),
            localState: .loaded(LocalWeekState(welcomeSaved: true, target: fixtureWeek(), savedAlbumID: nil, savedAlbumCount: 0)),
            eligiblePhotoCount: .loaded(0),
            creationAccess: .loaded(.inactive)
        )
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .noEligiblePhotos(.limited))
    }

    func testWelcomeWithNoPhotosIsHonestEmptyState() {
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.authorized),
            localState: .loaded(LocalWeekState(welcomeSaved: false, target: nil, savedAlbumID: nil, savedAlbumCount: 0)),
            eligiblePhotoCount: .loaded(0),
            creationAccess: nil
        )
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .noEligiblePhotos(.full))
    }

    func testWelcomeWithPhotosBecomesPendingWithoutEntitlementLookup() {
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.authorized),
            localState: .loaded(LocalWeekState(welcomeSaved: false, target: nil, savedAlbumID: nil, savedAlbumCount: 0)),
            eligiblePhotoCount: .loaded(3),
            creationAccess: nil
        )
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .welcomePending(.full))
    }

    func testSavedAlbumPrecedesGate() {
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.authorized),
            localState: .loaded(LocalWeekState(welcomeSaved: true, target: fixtureWeek(), savedAlbumID: UUID(), savedAlbumCount: 2)),
            eligiblePhotoCount: nil,
            creationAccess: nil
        )
        if case .saved = reducer.reduce(snapshot: snapshot) { } else { XCTFail("Saved album must remain readable") }
    }

    func testFreeLimitLocksOnlyWhenPhotosExist() {
        let local = LocalWeekState(welcomeSaved: true, target: fixtureWeek(), savedAlbumID: nil, savedAlbumCount: 2)
        let snapshot = WeekRootSnapshot(permission: .loaded(.authorized), localState: .loaded(local), eligiblePhotoCount: .loaded(4), creationAccess: .loaded(.inactive))
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .entitlementLocked)
    }

    func testUnknownEntitlementDoesNotBecomeInactive() {
        let local = LocalWeekState(welcomeSaved: true, target: fixtureWeek(), savedAlbumID: nil, savedAlbumCount: 2)
        let snapshot = WeekRootSnapshot(permission: .loaded(.authorized), localState: .loaded(local), eligiblePhotoCount: .loaded(4), creationAccess: .loaded(.unknown))
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .loading(.entitlement))
    }

    func testFreeRegularAlbumsDoNotWaitForUnknownEntitlement() {
        let local = LocalWeekState(welcomeSaved: true, target: fixtureWeek(), savedAlbumID: nil, savedAlbumCount: 1)
        let snapshot = WeekRootSnapshot(
            permission: .loaded(.authorized),
            localState: .loaded(local),
            eligiblePhotoCount: .loaded(4),
            creationAccess: .loaded(.unknown)
        )
        XCTAssertEqual(reducer.reduce(snapshot: snapshot), .ready(.full, photoCount: 4))
    }

    private func fixtureWeek() -> WeekRange {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        return WeekRange(key: "2026-W32", start: start, end: start.addingTimeInterval(604_800), cutoff: start.addingTimeInterval(604_800), eligibleFrom: start.addingTimeInterval(604_800), eligibleUntil: start.addingTimeInterval(1_209_600), kind: .regular)
    }
}

final class ReviewInteractionReducerTests: XCTestCase {
    private let reducer = ReviewInteractionReducer()

    func testFirstTapSelectsWithoutOpeningViewer() {
        let state = reducer.reduce(.initial, action: .tapPhoto(index: 1), photoCount: 7)
        XCTAssertEqual(state.selectedIndex, 1)
        XCTAssertNil(state.destination)
    }

    func testSecondTapOnSelectedPhotoOpensViewer() {
        let selected = ReviewPresentationState(selectedIndex: 1, destination: nil)
        let state = reducer.reduce(selected, action: .tapPhoto(index: 1), photoCount: 7)
        XCTAssertEqual(state.destination, .viewer(index: 1))
    }

    func testDirectAccessibilityActionsBypassTapSequence() {
        XCTAssertEqual(reducer.reduce(.initial, action: .viewPhoto(index: 3), photoCount: 7).destination, .viewer(index: 3))
        XCTAssertEqual(reducer.reduce(.initial, action: .replacePhoto(index: 4), photoCount: 7).destination, .replacement(index: 4))
    }

    func testInvalidIndexLeavesStateUntouched() {
        XCTAssertEqual(reducer.reduce(.initial, action: .tapPhoto(index: 7), photoCount: 7), .initial)
    }
}

final class ReviewActivityTrackerTests: XCTestCase {
    func testBackgroundTimeIsExcludedFromActiveReviewDuration() {
        let start = Date(timeIntervalSince1970: 1_000)
        var tracker = ReviewActivityTracker()

        tracker.setActive(true, at: start)
        tracker.setActive(false, at: start.addingTimeInterval(10))
        tracker.setActive(true, at: start.addingTimeInterval(100))

        XCTAssertEqual(tracker.elapsed(at: start.addingTimeInterval(105)), 15, accuracy: 0.001)
    }

    func testRepeatedVisibilityTransitionsDoNotDoubleCount() {
        let start = Date(timeIntervalSince1970: 2_000)
        var tracker = ReviewActivityTracker()

        tracker.setActive(true, at: start)
        tracker.setActive(true, at: start.addingTimeInterval(5))
        tracker.setActive(false, at: start.addingTimeInterval(8))
        tracker.setActive(false, at: start.addingTimeInterval(20))

        XCTAssertEqual(tracker.elapsed(at: start.addingTimeInterval(20)), 8, accuracy: 0.001)
    }
}

final class CurationEngineTests: XCTestCase {
    func testSelectionAndAlternativesStayWithinSevenAndDisjoint() throws {
        let descriptors = makeDescriptors(count: 100)
        let candidates = descriptors.map { descriptor in
            PhotoCandidate(descriptor: descriptor, aestheticsScore: 0.8, technicalScore: 0.9, faceCompositionScore: nil, duplicateGroup: nil)
        }
        let week = WeekRange(key: "2026-W32", start: descriptors.first!.capturedAt, end: descriptors.last!.capturedAt.addingTimeInterval(1), cutoff: descriptors.last!.capturedAt, eligibleFrom: nil, eligibleUntil: nil, kind: .regular)
        let draft = try CurationEngine().makeDraft(kind: .regular, week: week, analysisCutoff: week.cutoff, descriptors: descriptors, candidates: candidates)
        XCTAssertEqual(draft.selected.count, 7)
        XCTAssertEqual(draft.alternatives.count, 7)
        XCTAssertTrue(Set(draft.selected.map(\.id)).isDisjoint(with: draft.alternatives.map(\.id)))
    }

    func testUnderSevenDoesNotBackfill() throws {
        let descriptors = makeDescriptors(count: 5)
        let candidates = descriptors.map { PhotoCandidate(descriptor: $0, aestheticsScore: 0.8, technicalScore: 0.9, faceCompositionScore: nil, duplicateGroup: nil) }
        let week = WeekRange(key: "welcome-test", start: descriptors.first!.capturedAt, end: descriptors.last!.capturedAt.addingTimeInterval(1), cutoff: descriptors.last!.capturedAt, eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        let draft = try CurationEngine().makeDraft(kind: .welcome, week: week, analysisCutoff: week.cutoff, descriptors: descriptors, candidates: candidates)
        XCTAssertEqual(draft.selected.count, 5)
        XCTAssertTrue(draft.alternatives.isEmpty)
    }

    func testMetadataPrefilterIsDeterministicAndCapsVisionWorkAtTwentyOne() {
        let descriptors = makeDescriptors(count: 500)
        let sampler = CandidateSampler()
        XCTAssertEqual(sampler.sample(descriptors, weekKey: "2026-W32"), sampler.sample(descriptors, weekKey: "2026-W32"))
        XCTAssertEqual(sampler.sample(descriptors, weekKey: "2026-W32").count, 21)
        XCTAssertEqual(sampler.maximumCount, MetadataCandidatePrefilter.maximumVisionCandidates)
    }

    func testMetadataPrefilterDistributesAcrossAvailableDaysBeforeTieBreakers() {
        let timeZone = TimeZone(identifier: "Asia/Seoul")!
        let calendar = Calendar(identifier: .gregorian)
        let start = ISO8601DateFormatter().date(from: "2026-08-03T01:00:00+09:00")!
        let descriptors = (0..<100).map { index in
            let day = index % 7
            let hour = (index / 7) % 24
            let capturedAt = calendar.date(byAdding: .hour, value: (day * 24) + hour, to: start)!
            return PhotoDescriptor(
                id: PhotoID("distributed-\(index)"),
                capturedAt: capturedAt,
                pixelWidth: index == 0 ? 4_000 : 1_200,
                pixelHeight: index == 0 ? 4_000 : 1_600,
                isFavorite: index == 1,
                isHidden: false,
                isScreenshot: false
            )
        }
        let sampler = MetadataCandidatePrefilter(timeZoneIdentifier: timeZone.identifier)
        let first = sampler.sample(descriptors, weekKey: "2026-W32")
        let second = sampler.sample(descriptors.shuffled(), weekKey: "2026-W32")

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.count, 21)

        var localCalendar = Calendar(identifier: .gregorian)
        localCalendar.timeZone = timeZone
        let dayCoverage = Set(first.map { localCalendar.startOfDay(for: $0.capturedAt) })
        XCTAssertEqual(dayCoverage.count, 7)
    }

    func testMetadataPrefilterInterleavesAvailableTimeBucketsWithinADay() {
        let timeZone = TimeZone(identifier: "UTC")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let start = ISO8601DateFormatter().date(from: "2026-08-03T00:00:00Z")!
        let hours = [1, 7, 13, 19]
        let descriptors = hours.flatMap { hour in
            (0..<20).map { index in
                PhotoDescriptor(
                    id: PhotoID("bucket-\(hour)-\(index)"),
                    capturedAt: calendar.date(byAdding: .minute, value: (hour * 60) + index, to: start)!,
                    pixelWidth: 1_200,
                    pixelHeight: 1_600,
                    isFavorite: false,
                    isHidden: false,
                    isScreenshot: false
                )
            }
        }

        let sample = MetadataCandidatePrefilter(
            maximumCount: 8,
            timeZoneIdentifier: timeZone.identifier
        ).sample(descriptors, weekKey: "2026-W32")
        let coveredBuckets = Set(sample.map { calendar.component(.hour, from: $0.capturedAt) / 4 })

        XCTAssertEqual(sample.count, 8)
        XCTAssertEqual(coveredBuckets, Set([0, 1, 3, 4]))
    }

    func testAnalysisBudgetExposesTheApprovedDescriptorAndVisionContracts() {
        let budget = CurationAnalysisBudget.v1

        XCTAssertEqual(budget.descriptorScanLimit, 500)
        XCTAssertEqual(budget.maximumVisionCandidates, 21)
        XCTAssertTrue((384...448).contains(budget.analysisPixelSize))
        XCTAssertEqual(budget.perAssetTimeoutNanoseconds, 1_500_000_000)
        XCTAssertEqual(budget.globalTimeoutNanoseconds, 12_000_000_000)
    }

    func testAnalysisBudgetCannotRaiseTheDescriptorOrVisionCaps() {
        let budget = CurationAnalysisBudget(
            descriptorScanLimit: 5_000,
            maximumVisionCandidates: 500,
            analysisPixelSize: 512,
            perAssetTimeoutNanoseconds: 1,
            globalTimeoutNanoseconds: 1
        )

        XCTAssertEqual(budget.descriptorScanLimit, 500)
        XCTAssertEqual(budget.maximumVisionCandidates, 21)
        XCTAssertEqual(budget.analysisPixelSize, 448)
        XCTAssertEqual(MetadataCandidatePrefilter(maximumCount: 500).maximumCount, 21)
    }

    func testAlternativesRetainAnUnusedCandidateForEachSelectedDayWhenAvailable() throws {
        let timeZoneIdentifier = "UTC"
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        var descriptors: [PhotoDescriptor] = []
        for index in 0..<14 {
            let dayOffset = (index / 2) * 86_400
            let timeOffset = (index % 2) * 3_600
            let capturedAt = start.addingTimeInterval(Double(dayOffset + timeOffset))
            descriptors.append(
                PhotoDescriptor(
                    id: PhotoID("day-pair-\(index)"),
                    capturedAt: capturedAt,
                    pixelWidth: 1_200,
                    pixelHeight: 1_600,
                    isFavorite: false,
                    isHidden: false,
                    isScreenshot: false
                )
            )
        }
        let candidates = descriptors.map {
            PhotoCandidate(descriptor: $0, aestheticsScore: 0.8, technicalScore: 0.9, faceCompositionScore: nil, duplicateGroup: nil)
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

        let draft = try CurationEngine(timeZoneIdentifier: timeZoneIdentifier).makeDraft(
            kind: .regular,
            week: week,
            analysisCutoff: week.cutoff,
            descriptors: descriptors,
            candidates: candidates
        )

        for selected in draft.selected {
            let hasSameDayAlternative = draft.alternatives.contains {
                $0.isOnSameCalendarDay(as: selected, timeZoneIdentifier: timeZoneIdentifier)
            }
            XCTAssertTrue(hasSameDayAlternative, "Expected an unused alternative for \(selected.id)")
        }
    }

    func testReplacementCandidatesStartWithSameCalendarDayAndRequireOptInForOtherDays() throws {
        let start = Date(timeIntervalSince1970: 1_750_000_000)
        let selected = PhotoReference(id: PhotoID("selected"), capturedAt: start, pixelWidth: 1_200, pixelHeight: 1_600, score: 0.9, source: .initial)
        let sameDay = PhotoReference(id: PhotoID("same-day"), capturedAt: start.addingTimeInterval(3_600), pixelWidth: 1_200, pixelHeight: 1_600, score: 0.8, source: .replacement)
        let otherDay = PhotoReference(id: PhotoID("other-day"), capturedAt: start.addingTimeInterval(86_400), pixelWidth: 1_200, pixelHeight: 1_600, score: 0.7, source: .replacement)
        let week = WeekRange(key: "replacement-test", start: start, end: start.addingTimeInterval(604_800), cutoff: start.addingTimeInterval(604_800), eligibleFrom: nil, eligibleUntil: nil, kind: .regular)
        let draft = try CurationDraft(id: UUID(), kind: .regular, week: week, analysisCutoff: week.cutoff, selected: [selected], alternatives: [sameDay, otherDay], replacementCount: 0, skippedAssetCount: 0).validated()

        XCTAssertEqual(draft.replacementCandidates(for: 0, timeZoneIdentifier: "UTC").map(\.id), [sameDay.id])
        XCTAssertEqual(draft.otherDayReplacementCandidates(for: 0, timeZoneIdentifier: "UTC").map(\.id), [otherDay.id])
        XCTAssertEqual(draft.replacementCandidates(for: 0, timeZoneIdentifier: "UTC", includingOtherDays: true).map(\.id), [sameDay.id, otherDay.id])
    }

    func testReplacementChangesOnlyOneSlotAndAvoidsDuplicate() throws {
        let descriptors = makeDescriptors(count: 14)
        let candidates = descriptors.map { PhotoCandidate(descriptor: $0, aestheticsScore: 0.8, technicalScore: 0.9, faceCompositionScore: nil, duplicateGroup: nil) }
        let start = descriptors.first!.capturedAt
        let week = WeekRange(key: "2026-W32", start: start, end: descriptors.last!.capturedAt.addingTimeInterval(1), cutoff: descriptors.last!.capturedAt, eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        let draft = try CurationEngine().makeDraft(kind: .welcome, week: week, analysisCutoff: week.cutoff, descriptors: descriptors, candidates: candidates)
        let replaced = try draft.replacing(index: 2, with: draft.alternatives[0])
        XCTAssertEqual(replaced.selected.count, draft.selected.count)
        XCTAssertEqual(replaced.replacementCount, 1)
        XCTAssertEqual(Set(replaced.selected.map(\.id)).count, replaced.selected.count)
        XCTAssertNotEqual(replaced.selected[2].id, draft.selected[2].id)
        for index in draft.selected.indices where index != 2 {
            XCTAssertEqual(replaced.selected[index].id, draft.selected[index].id)
        }
    }

    func testReplacementRejectsCandidateOutsideAlternatives() throws {
        let descriptors = makeDescriptors(count: 14)
        let candidates = descriptors.map { PhotoCandidate(descriptor: $0, aestheticsScore: 0.8, technicalScore: 0.9, faceCompositionScore: nil, duplicateGroup: nil) }
        let start = descriptors.first!.capturedAt
        let week = WeekRange(key: "welcome-test", start: start, end: descriptors.last!.capturedAt.addingTimeInterval(1), cutoff: descriptors.last!.capturedAt, eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        let draft = try CurationEngine().makeDraft(kind: .welcome, week: week, analysisCutoff: week.cutoff, descriptors: descriptors, candidates: candidates)
        let unavailable = PhotoReference(id: PhotoID("not-an-alternative"), capturedAt: start, pixelWidth: 1_200, pixelHeight: 1_600, score: 0.8, source: .replacement)

        XCTAssertThrowsError(try draft.replacing(index: 0, with: unavailable)) { error in
            XCTAssertEqual(error as? CurationDraft.DraftError, .candidateUnavailable)
        }
    }

    func testWelcomeDraftRejectsPhotoOutsideRequestedRange() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let week = WeekRange(key: "welcome-test", start: start, end: start.addingTimeInterval(604_800), cutoff: start.addingTimeInterval(604_800), eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        let outside = PhotoReference(id: PhotoID("outside"), capturedAt: week.end, pixelWidth: 1_200, pixelHeight: 1_600, score: 0.8, source: .initial)
        let draft = CurationDraft(id: UUID(), kind: .welcome, week: week, analysisCutoff: week.cutoff, selected: [outside], alternatives: [], replacementCount: 0, skippedAssetCount: 0)

        XCTAssertThrowsError(try draft.validated()) { error in
            XCTAssertEqual(error as? CurationDraft.DraftError, .photoOutsideWeek)
        }
    }

    func testDraftRejectsDuplicateAlternatives() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let week = WeekRange(key: "welcome-test", start: start, end: start.addingTimeInterval(604_800), cutoff: start.addingTimeInterval(604_800), eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        let selected = PhotoReference(id: PhotoID("selected"), capturedAt: start, pixelWidth: 1_200, pixelHeight: 1_600, score: 0.8, source: .initial)
        let alternative = PhotoReference(id: PhotoID("alternative"), capturedAt: start.addingTimeInterval(60), pixelWidth: 1_200, pixelHeight: 1_600, score: 0.7, source: .replacement)
        let draft = CurationDraft(id: UUID(), kind: .welcome, week: week, analysisCutoff: week.cutoff, selected: [selected], alternatives: [alternative, alternative], replacementCount: 0, skippedAssetCount: 0)

        XCTAssertThrowsError(try draft.validated()) { error in
            XCTAssertEqual(error as? CurationDraft.DraftError, .duplicatePhoto)
        }
    }

    private func makeDescriptors(count: Int) -> [PhotoDescriptor] {
        (0..<count).map { index in
            PhotoDescriptor(id: PhotoID("test-\(index)"), capturedAt: Date(timeIntervalSince1970: 1_700_000_000 + Double(index * 600)), pixelWidth: 1_200, pixelHeight: 1_600, isFavorite: index == 0, isHidden: false, isScreenshot: false)
        }
    }
}

final class BoundedPhotoFetchIndexSamplerTests: XCTestCase {
    func testUnderLimitKeepsEveryChronologicalIndex() {
        XCTAssertEqual(
            BoundedPhotoFetchIndexSampler.indices(totalCount: 7, limit: 500),
            Array(0..<7)
        )
    }

    func testOverLimitCoversTheWholeChronologicalRangeWithoutDuplicates() {
        let indices = BoundedPhotoFetchIndexSampler.indices(totalCount: 1_000, limit: 500)

        XCTAssertEqual(indices.count, 500)
        XCTAssertEqual(indices.first, 0)
        XCTAssertEqual(indices.last, 999)
        XCTAssertEqual(Set(indices).count, indices.count)
        XCTAssertTrue(zip(indices, indices.dropFirst()).allSatisfy { $0 < $1 })
    }
}

final class VisionPhotoAnalysisTests: XCTestCase {
    func testVisionAnalyzerProducesBoundedSignalsForFixtureImage() async throws {
        let library = FixturePhotoLibraryClient()
        let image = try await library.analysisImage(
            for: PhotoID("fixture-photo-0"),
            targetSize: CGSize(width: 160, height: 160)
        )
        let signals = try await VisionPhotoAnalyzer().analyze(
            imageData: image.data,
            photoID: PhotoID("fixture-photo-0")
        )

        XCTAssertTrue((0...1).contains(signals.aestheticsScore))
        XCTAssertTrue((0...1).contains(signals.technicalScore))
    }
}

final class PersistenceAndPolicyTests: XCTestCase {
    func testSwiftDataAlbumUpsertIsAtomicAndUniqueByWeekKey() async throws {
        let container = try WeekkeepSchema.previewContainer()
        let store = SwiftDataAlbumStore(modelContainer: container)
        let draft = try makeDraft()

        let first = try await store.upsert(draft)
        let second = try await store.upsert(draft)

        XCTAssertEqual(first.weekKey, second.weekKey)
        XCTAssertEqual(first.id, second.id)
        let savedCount = try await store.savedAlbumCount()
        let savedAlbum = try await store.album(for: draft.week.key)
        XCTAssertEqual(savedCount, 1)
        XCTAssertEqual(savedAlbum?.photos.count, draft.selected.count)
    }

    func testInMemoryAlbumUpsertIsIdempotentByWeekKey() async throws {
        let store = InMemoryAlbumStore()
        let draft = try makeDraft()
        _ = try await store.upsert(draft)
        _ = try await store.upsert(draft)
        let count = try await store.savedAlbumCount()
        let albums = try await store.listAlbums()
        XCTAssertEqual(count, 1)
        XCTAssertEqual(albums.count, 1)
    }

    func testUnavailableAlbumStoreSurfacesFailureInsteadOfUsingTemporaryStorage() async {
        let store = UnavailableAlbumStore()

        do {
            _ = try await store.listAlbums()
            XCTFail("Unavailable durable storage must throw")
        } catch {
            XCTAssertEqual(error as? AlbumStoreError, .unavailable)
        }
    }

    func testFreeGateAndArchiveReadPolicy() {
        let policy = EntitlementPolicy()
        XCTAssertTrue(policy.canCreate(savedAlbumCount: 0, entitlement: .inactive))
        XCTAssertTrue(policy.canCreate(savedAlbumCount: 1, entitlement: .inactive))
        XCTAssertFalse(policy.canCreate(savedAlbumCount: 2, entitlement: .inactive))
        XCTAssertFalse(policy.canCreate(savedAlbumCount: 2, entitlement: .unknown))
        XCTAssertTrue(policy.shouldShowPaywall(targetIsSaved: false, eligiblePhotoCount: 3, savedAlbumCount: 2, entitlement: .inactive))
        XCTAssertFalse(policy.shouldShowPaywall(targetIsSaved: true, eligiblePhotoCount: 3, savedAlbumCount: 2, entitlement: .inactive))
        XCTAssertFalse(policy.shouldShowPaywall(targetIsSaved: false, eligiblePhotoCount: 0, savedAlbumCount: 2, entitlement: .inactive))
    }

    func testSevenStitchContractIsExactSeven() {
        XCTAssertEqual(SevenStitchRail.stitchCount, 7)
    }

    private func makeDraft() throws -> CurationDraft {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let photos = (0..<3).map { index in
            PhotoReference(id: PhotoID("album-\(index)"), capturedAt: start.addingTimeInterval(Double(index * 600)), pixelWidth: 1_200, pixelHeight: 1_600, score: 0.8, source: .initial)
        }
        let week = WeekRange(key: "welcome-test", start: start, end: start.addingTimeInterval(604_800), cutoff: start.addingTimeInterval(604_800), eligibleFrom: nil, eligibleUntil: nil, kind: .welcome)
        return try CurationDraft(id: UUID(), kind: .welcome, week: week, analysisCutoff: week.cutoff, selected: photos, alternatives: [], replacementCount: 0, skippedAssetCount: 0).validated()
    }
}

final class AnalyticsAndDeepLinkTests: XCTestCase {
    func testPhotoPermissionAnalyticsUsesStablePrivacySafeBuckets() {
        XCTAssertEqual(PhotoAuthorization.authorized.analyticsValue, "full")
        XCTAssertEqual(PhotoAuthorization.limited.analyticsValue, "limited")
        XCTAssertEqual(PhotoAuthorization.denied.analyticsValue, "denied")
        XCTAssertEqual(PhotoAuthorization.restricted.analyticsValue, "restricted")
        XCTAssertEqual(PhotoAuthorization.notDetermined.analyticsValue, "not_determined")
    }

    func testAnalyticsSchemaRejectsPhotoLikeKeysAndAllowsTypedEvent() {
        let event = AnalyticsEvent.albumSaved(
            albumKind: .regular,
            regularSequenceBucket: "w1",
            selectedCount: 7,
            replacementCount: 1,
            activeReviewDurationBucket: "under_30s"
        )
        XCTAssertTrue(AnalyticsSchema.validate(event))
        XCTAssertEqual(AnalyticsSchema.sanitizedProperties(for: event)?["selected_count"], "7")
        XCTAssertFalse(AnalyticsSchema.allowedPropertyKeys["album_saved"]?.contains("filename") == true)
        XCTAssertFalse(AnalyticsSchema.isSafeKey("photo_localIdentifier"))
        XCTAssertFalse(AnalyticsSchema.isSafeValue("photo-local-id"))
        XCTAssertFalse(AnalyticsSchema.forbiddenFragments.isEmpty)

        let shareEvent = AnalyticsEvent.shareSheetOpened(
            format: .post,
            entryPoint: .saveConfirmation
        )
        XCTAssertTrue(AnalyticsSchema.validate(shareEvent))
        XCTAssertEqual(shareEvent.name, "share_sheet_opened")
        XCTAssertEqual(
            AnalyticsSchema.sanitizedProperties(for: shareEvent),
            ["format": "post", "entry_point": "save_confirmation"]
        )
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "share_sheet_opened",
                properties: ["format": "square", "entry_point": "save_confirmation"]
            )
        )
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "share_sheet_opened",
                properties: ["format": "story", "entry_point": "message_recipient"]
            )
        )

        let weeklyReturn = AnalyticsEvent.eligibleWeekOpened(entryPoint: .notification)
        XCTAssertTrue(AnalyticsSchema.validate(weeklyReturn))
        XCTAssertEqual(weeklyReturn.name, "eligible_week_opened")
        XCTAssertEqual(weeklyReturn.properties, ["entry_point": "notification"])
        XCTAssertNil(
            AnalyticsSchema.sanitizedProperties(
                eventName: "eligible_week_opened",
                properties: ["entry_point": "unknown"]
            )
        )
    }

    func testDeepLinksNeverAcceptPhotoIdentifiers() {
        let router = AppRouter()
        XCTAssertEqual(router.parse(URL(string: "weekkeep://weekly/current")!), .weeklyCurrent)
        XCTAssertEqual(router.parse(URL(string: "weekkeep://album/2026-W32")!), .album(weekKey: "2026-W32"))
        XCTAssertNil(router.parse(URL(string: "weekkeep://album/photo-local-id")!))
        XCTAssertNil(router.parse(URL(string: "weekkeep://weekly/current?photoID=photo-local-id")!))
        XCTAssertNil(router.parse(URL(string: "weekkeep://plus#photo-local-id")!))
    }

    func testNotificationUserInfoParsesOnlyApprovedDeepLinks() {
        XCTAssertEqual(
            NotificationDeepLinkParser.parse(userInfo: ["deepLink": "weekkeep://weekly/current"]),
            .weeklyCurrent
        )
        XCTAssertEqual(
            NotificationDeepLinkParser.parse(userInfo: ["deepLink": "weekkeep://plus"]),
            .plus
        )
        XCTAssertNil(
            NotificationDeepLinkParser.parse(userInfo: ["deepLink": "weekkeep://weekly/current?photoID=photo-local-id"])
        )
        XCTAssertNil(
            NotificationDeepLinkParser.parse(userInfo: ["deepLink": "weekkeep://album/photo-local-id"])
        )
        XCTAssertNil(NotificationDeepLinkParser.parse(userInfo: ["deepLink": 42]))
        XCTAssertNil(NotificationDeepLinkParser.parse(userInfo: ["deepLink": "https://example.com/weekly/current"]))
    }

    @MainActor
    func testAppRouterRoutesNotificationDeepLinkToWeekTabAndPendingEnvironmentState() {
        let environment = AppEnvironment.fixtures()
        environment.selectedTab = .archive

        environment.appRouter.route(
            .weeklyCurrent,
            in: environment,
            entryPoint: .notification
        )

        XCTAssertEqual(environment.selectedTab, .week)
        XCTAssertEqual(environment.pendingDeepLink, .weeklyCurrent)
        XCTAssertEqual(environment.pendingWeeklyEntryPoint, .notification)
    }
}

@MainActor
final class WeeklyDeepLinkConsumptionTests: XCTestCase {
    func testWeeklyCurrentPendingLinkIsConsumedOnInitialWeeklyModelAppearance() async {
        let environment = AppEnvironment.fixtures()
        let model = WeeklyFlowModel(environment: environment)
        environment.pendingDeepLink = .weeklyCurrent

        let action = await model.consumePendingDeepLink()

        XCTAssertEqual(action, .refreshWeekly)
        XCTAssertNil(environment.pendingDeepLink)
    }

    func testPlusPendingLinkIsConsumedAndPresentsPaywallOnInitialWeeklyModelAppearance() async {
        let environment = AppEnvironment.fixtures()
        let model = WeeklyFlowModel(environment: environment)
        environment.pendingDeepLink = .plus

        let action = await model.consumePendingDeepLink()

        XCTAssertEqual(action, .presentPlus)
        XCTAssertNil(environment.pendingDeepLink)
        XCTAssertEqual(model.sheet, .paywall)
    }
}

@MainActor
final class WeeklyCurationCancellationTests: XCTestCase {
    func testCancelThenImmediateRestartIgnoresStaleCallbacksAndKeepsNewRunCancelable() async throws {
        let analysisService = ControlledPhotoAnalysisService()
        let photoLibrary = FixturePhotoLibraryClient(
            descriptors: FixturePhotoLibraryClient.makeDescriptors(count: 3)
        )
        let suiteName = "weekkeep.curation.cancel.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let environment = AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: analysisService,
            albumStore: InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: defaults,
            isFixture: true
        )
        let model = WeeklyFlowModel(environment: environment)

        await model.refresh()
        model.startCuration()
        let firstRunStarted = await waitForRun(0, service: analysisService)
        XCTAssertTrue(firstRunStarted)
        guard firstRunStarted else { return }

        model.cancelCuration()
        model.startCuration()
        let secondRunStarted = await waitForRun(1, service: analysisService)
        XCTAssertTrue(secondRunStarted)
        guard secondRunStarted else { return }
        XCTAssertEqual(model.route, .curation)

        let initialProgress = CurationProgress(
            stage: .fetchingAssets,
            completed: 0,
            total: 0,
            skippedCount: 0
        )
        let staleProgress = CurationProgress(
            stage: .ranking,
            completed: 99,
            total: 99,
            skippedCount: 0
        )
        let currentProgress = CurationProgress(
            stage: .analyzing,
            completed: 1,
            total: 3,
            skippedCount: 0
        )

        await analysisService.sendProgress(run: 0, progress: staleProgress)
        await settleMainActorCallbacks()
        XCTAssertEqual(model.progress, initialProgress)

        await analysisService.complete(run: 0)
        let firstRunWasCancelledAtResume = await analysisService.waitForCancellationAtResume(0)
        XCTAssertTrue(firstRunWasCancelledAtResume)
        await settleMainActorCallbacks()
        XCTAssertEqual(model.route, .curation)
        XCTAssertNil(model.draft)
        XCTAssertEqual(model.progress, initialProgress)
        XCTAssertNil(model.errorMessage)

        model.startCuration()
        let runOneTaskHandleWasPreserved = await waitForRunToRemainUnstarted(2, service: analysisService)
        XCTAssertTrue(runOneTaskHandleWasPreserved)

        await analysisService.sendProgress(run: 1, progress: currentProgress)
        await settleMainActorCallbacks()
        XCTAssertEqual(model.progress, currentProgress)

        model.cancelCuration()
        model.startCuration()
        let thirdRunStarted = await waitForRun(2, service: analysisService)
        XCTAssertTrue(thirdRunStarted)
        guard thirdRunStarted else { return }

        let nextRunProgress = CurationProgress(
            stage: .analyzing,
            completed: 2,
            total: 3,
            skippedCount: 1
        )

        await analysisService.sendProgress(run: 2, progress: nextRunProgress)
        await settleMainActorCallbacks()
        XCTAssertEqual(model.progress, nextRunProgress)

        await analysisService.cancel(run: 1)
        let secondRunWasCancelledAtResume = await analysisService.waitForCancellationAtResume(1)
        await settleMainActorCallbacks()
        XCTAssertTrue(secondRunWasCancelledAtResume)
        XCTAssertEqual(model.route, .curation)
        XCTAssertNil(model.draft)
        XCTAssertEqual(model.progress, nextRunProgress)
        XCTAssertNil(model.errorMessage)

        await analysisService.sendProgress(run: 1, progress: staleProgress)
        await settleMainActorCallbacks()
        XCTAssertEqual(model.progress, nextRunProgress)

        model.startCuration()
        let runTwoTaskHandleWasPreserved = await waitForRunToRemainUnstarted(3, service: analysisService)
        XCTAssertTrue(runTwoTaskHandleWasPreserved)

        model.cancelCuration()
        await analysisService.complete(run: 2)
        let thirdRunWasCancelledAtResume = await analysisService.waitForCancellationAtResume(2)
        await settleMainActorCallbacks()

        XCTAssertTrue(thirdRunWasCancelledAtResume)
        XCTAssertNil(model.route)
        XCTAssertNil(model.draft)
        XCTAssertNil(model.progress)
    }

    private func waitForRun(
        _ run: Int,
        service: ControlledPhotoAnalysisService
    ) async -> Bool {
        for _ in 0..<100 {
            if await service.hasStarted(run) { return true }
            await Task.yield()
        }
        return false
    }

    private func waitForRunToRemainUnstarted(
        _ run: Int,
        service: ControlledPhotoAnalysisService
    ) async -> Bool {
        for _ in 0..<100 {
            if await service.hasStarted(run) { return false }
            await Task.yield()
        }
        return true
    }

    private func settleMainActorCallbacks() async {
        for _ in 0..<8 {
            await Task.yield()
        }
    }
}

@MainActor
final class FirstAlbumCurationPinningTests: XCTestCase {
    func testStartCurationUsesTheRangeResolvedByTheRootFallback() async throws {
        let now = ISO8601DateFormatter().date(from: "2026-08-05T12:00:00+09:00")!
        let descriptors = (0..<3).map { index in
            PhotoDescriptor(
                id: PhotoID("first-album-fallback-\(index)"),
                capturedAt: now.addingTimeInterval(Double(index - 48) * 60 * 60),
                pixelWidth: 1_200,
                pixelHeight: 1_600,
                isFavorite: false,
                isHidden: false,
                isScreenshot: false
            )
        }
        let photoLibrary = FixturePhotoLibraryClient(descriptors: descriptors)
        let analysisService = ControlledPhotoAnalysisService()
        let suiteName = "weekkeep.first-album.pin.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let environment = AppEnvironment(
            photoLibrary: photoLibrary,
            analysisService: analysisService,
            albumStore: InMemoryAlbumStore(),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: defaults,
            isFixture: true,
            timeZone: TimeZone(identifier: "Asia/Seoul")!
        )
        let model = WeeklyFlowModel(environment: environment, nowProvider: { now })

        await model.refresh()
        XCTAssertEqual(model.firstAlbumRangeStrategy, .rollingSevenDayFallback)
        let resolved = try XCTUnwrap(model.resolvedCurationRange)

        model.startCuration()
        var started = false
        for _ in 0..<100 {
            if await analysisService.hasStarted(0) {
                started = true
                break
            }
            await Task.yield()
        }

        XCTAssertTrue(started)
        let requestedWeekOptional = await analysisService.week(for: 0)
        let requestedWeek = try XCTUnwrap(requestedWeekOptional)
        XCTAssertEqual(requestedWeek, resolved)
        XCTAssertEqual(resolved.welcomeAlbumRangeStrategy, .rollingSevenDayFallback)
        model.cancelCuration()
        await analysisService.cancel(run: 0)
    }

    @MainActor
    func testPersistedCycleIsPreservedForLegacyRollingWelcome() async throws {
        let timeZone = TimeZone(identifier: "Asia/Seoul")!
        let savedAt = ISO8601DateFormatter().date(from: "2026-08-05T18:00:00+09:00")!
        let calculator = WeekRangeCalculator(timeZone: timeZone)
        let legacyRange = calculator.welcomeRange(analysisStartedAt: savedAt)
        let album = WeeklyAlbumSnapshot(
            id: UUID(),
            weekKey: legacyRange.key,
            kind: .welcome,
            weekStart: legacyRange.start,
            weekEnd: legacyRange.end,
            analysisCutoff: legacyRange.cutoff,
            createdAt: savedAt,
            updatedAt: savedAt,
            coverPhotoID: nil,
            photos: []
        )
        let suiteName = "weekkeep.legacy-cycle.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let persistedCycle = ISO8601DateFormatter().date(from: "2026-08-24T00:00:00+09:00")!
        let environment = AppEnvironment(
            photoLibrary: FixturePhotoLibraryClient(descriptors: []),
            analysisService: ControlledPhotoAnalysisService(),
            albumStore: InMemoryAlbumStore(initialAlbums: [album]),
            purchaseClient: FixturePurchaseClient(),
            notificationClient: FixtureNotificationClient(),
            analyticsClient: NoopAnalyticsClient(),
            defaults: defaults,
            isFixture: true,
            timeZone: timeZone
        )
        environment.regularCycleStartsAt = persistedCycle

        let model = WeeklyFlowModel(
            environment: environment,
            nowProvider: { savedAt }
        )
        await model.refresh()

        XCTAssertEqual(environment.regularCycleStartsAt, persistedCycle)
    }
}

private actor ControlledPhotoAnalysisService: PhotoAnalysisService {
    private struct RunRequest {
        let kind: AlbumKind
        let week: WeekRange
        let analysisCutoff: Date
    }

    private var nextRun = 0
    private var startedRuns = Set<Int>()
    private var requests: [Int: RunRequest] = [:]
    private var progressCallbacks: [Int: @Sendable (CurationProgress) -> Void] = [:]
    private var continuations: [Int: CheckedContinuation<CurationDraft, Error>] = [:]
    private var cancellationAtResume: [Int: Bool] = [:]
    private var cancellationEvidenceWaiters: [Int: [CheckedContinuation<Bool, Never>]] = [:]

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft {
        let run = nextRun
        nextRun += 1
        startedRuns.insert(run)
        requests[run] = RunRequest(kind: kind, week: week, analysisCutoff: analysisCutoff)
        progressCallbacks[run] = progress

        do {
            let draft = try await withCheckedThrowingContinuation { continuation in
                continuations[run] = continuation
            }
            recordCancellationAtResume(for: run)
            return draft
        } catch {
            recordCancellationAtResume(for: run)
            throw error
        }
    }

    func hasStarted(_ run: Int) -> Bool {
        startedRuns.contains(run)
    }

    func week(for run: Int) -> WeekRange? {
        requests[run]?.week
    }

    func waitForCancellationAtResume(_ run: Int) async -> Bool {
        if let value = cancellationAtResume[run] { return value }
        return await withCheckedContinuation { continuation in
            cancellationEvidenceWaiters[run, default: []].append(continuation)
        }
    }

    func sendProgress(run: Int, progress: CurationProgress) {
        progressCallbacks[run]?(progress)
    }

    func cancel(run: Int) {
        continuations.removeValue(forKey: run)?.resume(throwing: CancellationError())
    }

    func complete(run: Int) {
        guard let request = requests[run] else { return }
        continuations.removeValue(forKey: run)?.resume(returning: makeDraft(for: request, run: run))
    }

    private func recordCancellationAtResume(for run: Int) {
        let value = Task.isCancelled
        cancellationAtResume[run] = value
        let waiters = cancellationEvidenceWaiters.removeValue(forKey: run) ?? []
        waiters.forEach { $0.resume(returning: value) }
    }

    private func makeDraft(for request: RunRequest, run: Int) -> CurationDraft {
        let photo = PhotoReference(
            id: PhotoID("controlled-\(run)"),
            capturedAt: request.week.start.addingTimeInterval(3_600),
            pixelWidth: 1_200,
            pixelHeight: 1_600,
            score: 0.8,
            source: .initial
        )
        return try! CurationDraft(
            id: UUID(),
            kind: request.kind,
            week: request.week,
            analysisCutoff: request.analysisCutoff,
            selected: [photo],
            alternatives: [],
            replacementCount: 0,
            skippedAssetCount: 0
        ).validated()
    }
}

final class AppConfigurationTests: XCTestCase {
    func testDisabledConfigurationDoesNotActivateEitherVendor() {
        let configuration = AppConfiguration(infoDictionary: [
            "WK_PURCHASES_ENABLED": "NO",
            "WK_REVENUECAT_API_KEY": "rc_public_key",
            "WK_ANALYTICS_ENABLED": "NO",
            "WK_POSTHOG_PROJECT_TOKEN": "ph_project_token",
            "WK_POSTHOG_HOST": "https://eu.i.posthog.com"
        ])

        XCTAssertFalse(configuration.hasValidPurchaseConfiguration)
        XCTAssertFalse(configuration.hasValidAnalyticsConfiguration)
    }

    func testValidConfigurationTrimsKeysAndRequiresPostHogEUHost() {
        let configuration = AppConfiguration(infoDictionary: [
            "WK_PURCHASES_ENABLED": "true",
            "WK_REVENUECAT_API_KEY": "  rc_public_key  ",
            "WK_ANALYTICS_ENABLED": "1",
            "WK_POSTHOG_PROJECT_TOKEN": "  ph_project_token  ",
            "WK_POSTHOG_HOST": "https://eu.i.posthog.com"
        ])

        XCTAssertEqual(configuration.revenueCatAPIKey, "rc_public_key")
        XCTAssertEqual(configuration.postHogProjectToken, "ph_project_token")
        XCTAssertTrue(configuration.hasValidPurchaseConfiguration)
        XCTAssertTrue(configuration.hasValidAnalyticsConfiguration)
    }

    func testNonEUOrMalformedHostFallsBackToSafeEUHost() {
        let configuration = AppConfiguration(infoDictionary: [
            "WK_ANALYTICS_ENABLED": "YES",
            "WK_POSTHOG_PROJECT_TOKEN": "token",
            "WK_POSTHOG_HOST": "https://us.i.posthog.com/path"
        ])

        XCTAssertEqual(configuration.postHogHost, AppConfiguration.euPostHogHost)
        XCTAssertTrue(configuration.hasValidAnalyticsConfiguration)
    }
}

final class PurchaseContractTests: XCTestCase {
    func testRevenueCatMappingsAreExact() {
        XCTAssertEqual(PurchaseContract.entitlementID, "plus")
        XCTAssertEqual(PurchaseContract.offeringID, "default")
        XCTAssertEqual(PurchaseContract.productID, "weekkeep_plus_lifetime")
    }

    func testDisabledPurchaseClientPreservesUnknownSafetyState() async {
        let client = DisabledPurchaseClient()
        let state = await client.entitlementState()
        XCTAssertEqual(state, .unknown)
        do {
            _ = try await client.currentOffering()
            XCTFail("Disabled purchases must not expose an offering")
        } catch {
            XCTAssertEqual(error as? PurchaseClientError, .unavailable)
        }
    }

    func testFixtureOfferingFollowsLanguageAndCurrency() {
        let english = FixturePurchaseClient.localizedOffering(
            preferredLocalization: "en",
            currencyCode: "USD"
        )
        let korean = FixturePurchaseClient.localizedOffering(
            preferredLocalization: "ko",
            currencyCode: "KRW"
        )

        XCTAssertEqual(english.productID, PurchaseContract.productID)
        XCTAssertEqual(english.localizedTitle, "Lifetime Plus access")
        XCTAssertEqual(english.localizedPrice, "$19.99")
        XCTAssertEqual(korean.productID, PurchaseContract.productID)
        XCTAssertEqual(korean.localizedTitle, "평생 Plus 이용권")
        XCTAssertEqual(korean.localizedPrice, "₩29,000")
    }
}

final class ResourceContractTests: XCTestCase {
    func testGeneratedSourceInfoPlistContainsLaunchAndStoreMetadata() throws {
        let plistURL = resourceURL("Weekkeep/Resources/Info.plist")
        let plist = try PropertyListSerialization.propertyList(
            from: Data(contentsOf: plistURL),
            options: [],
            format: nil
        ) as! [String: Any]

        XCTAssertEqual(plist["CFBundleShortVersionString"] as? String, "$(MARKETING_VERSION)")
        XCTAssertEqual(plist["CFBundleVersion"] as? String, "$(CURRENT_PROJECT_VERSION)")
        XCTAssertEqual(plist["ITSAppUsesNonExemptEncryption"] as? Bool, false)
        XCTAssertEqual(plist["LSApplicationCategoryType"] as? String, "public.app-category.photo-video")
        XCTAssertEqual(plist["UIUserInterfaceStyle"] as? String, "Light")
        XCTAssertEqual(plist["UILaunchScreen"] as? [String: String], ["UIColorName": "LaunchBackground"])
        XCTAssertEqual(plist["UISupportedInterfaceOrientations"] as? [String], ["UIInterfaceOrientationPortrait"])
        XCTAssertNotNil(plist["UIApplicationSceneManifest"])
        XCTAssertNotNil(plist["CFBundleURLTypes"])
        XCTAssertNotNil(plist["NSPhotoLibraryUsageDescription"])
        XCTAssertEqual(plist["UIAppFonts"] as? [String], ["LINESeedKR-Rg.ttf", "LINESeedKR-Bd.ttf"])
    }

    func testStringCatalogHasCompleteLocalizationsAndTypedPluralContracts() throws {
        let catalogURL = resourceURL("Weekkeep/Resources/Localizable.xcstrings")
        let catalogData = try Data(contentsOf: catalogURL)
        let catalog = try XCTUnwrap(JSONSerialization.jsonObject(with: catalogData) as? [String: Any])
        XCTAssertEqual(catalog["sourceLanguage"] as? String, "en")
        XCTAssertEqual(catalog["version"] as? String, "1.0")

        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])
        XCTAssertEqual(strings.count, 220)
        XCTAssertFalse(FileManager.default.fileExists(atPath: resourceURL("Weekkeep/Resources/en.lproj/Localizable.strings").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: resourceURL("Weekkeep/Resources/ko.lproj/Localizable.strings").path))

        let requiredPluralKeys = [
            "week.photoCount",
            "review.body",
            "review.bodyCount",
            "review.keep",
            "save.metadata",
            "archive.photoCount",
            "detail.savedOnDevice",
            "paywall.overlineCount"
        ]
        for key in requiredPluralKeys {
            let entry = try XCTUnwrap(strings[key] as? [String: Any], "Missing catalog key: \(key)")
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any])
            XCTAssertEqual(Set(localizations.keys), Set(["en", "ko"]), "Incomplete locales for \(key)")
            for locale in ["en", "ko"] {
                let localization = try XCTUnwrap(localizations[locale] as? [String: Any])
                let plural = pluralVariants(in: localization)
                XCTAssertEqual(Set(plural.keys), Set(["one", "other"]), "Malformed plural variants for \(key)/\(locale)")
                let values = try pluralValues(plural)
                XCTAssertTrue(values.allSatisfy { $0.contains("%lld") }, "Untyped count in \(key)/\(locale)")
                XCTAssertTrue(values.allSatisfy { !$0.contains("%@") }, "String count placeholder in \(key)/\(locale)")
            }
        }

        let viewerFormats: [String: (String, String)] = [
            "review.photoLabel": ("Photo %2$lld of %1$lld", "%1$lld장 중 %2$lld번째 사진"),
            "viewer.position": ("%1$lld of %2$lld", "%2$lld장 중 %1$lld번째"),
            "accessibility.photo": ("Photo %2$lld of %1$lld", "%1$lld장 중 %2$lld번째 사진")
        ]
        for (key, expected) in viewerFormats {
            let entry = try XCTUnwrap(strings[key] as? [String: Any])
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any])
            let english = try XCTUnwrap(localizations["en"] as? [String: Any])
            let korean = try XCTUnwrap(localizations["ko"] as? [String: Any])
            XCTAssertEqual(stringUnitValue(in: english), expected.0, "English format drifted for \(key)")
            XCTAssertEqual(stringUnitValue(in: korean), expected.1, "Korean format drifted for \(key)")
        }

        let bodyCountEntry = try XCTUnwrap(strings["review.bodyCount"] as? [String: Any])
        let bodyCountLocalizations = try XCTUnwrap(bodyCountEntry["localizations"] as? [String: Any])
        for locale in ["en", "ko"] {
            let localization = try XCTUnwrap(bodyCountLocalizations[locale] as? [String: Any])
            XCTAssertEqual(stringUnitValue(in: localization), locale == "en" ? "%2$lld / %#@total@" : "사진 %2$lld / %#@total@")
            let substitutions = try XCTUnwrap(localization["substitutions"] as? [String: Any])
            let total = try XCTUnwrap(substitutions["total"] as? [String: Any])
            XCTAssertEqual(total["argNum"] as? Int, 1)
            XCTAssertEqual(total["formatSpecifier"] as? String, "lld")
            let variations = try XCTUnwrap(total["variations"] as? [String: Any])
            XCTAssertNotNil(variations["plural"] as? [String: Any])
        }

        let englishInfo = try localizedKeys(at: resourceURL("Weekkeep/Resources/en.lproj/InfoPlist.strings"))
        let koreanInfo = try localizedKeys(at: resourceURL("Weekkeep/Resources/ko.lproj/InfoPlist.strings"))
        XCTAssertEqual(englishInfo, koreanInfo)

        let englishInfoCopy = try String(contentsOf: resourceURL("Weekkeep/Resources/en.lproj/InfoPlist.strings"), encoding: .utf8)
        let koreanInfoCopy = try String(contentsOf: resourceURL("Weekkeep/Resources/ko.lproj/InfoPlist.strings"), encoding: .utf8)
        XCTAssertTrue(englishInfoCopy.contains("most recently completed Monday–Sunday week"))
        XCTAssertTrue(englishInfoCopy.contains("most recent 7 days"))
        XCTAssertTrue(englishInfoCopy.contains("Photos are processed on your iPhone"))
        XCTAssertTrue(koreanInfoCopy.contains("최근 완료된 월요일부터 일요일까지의 한 주에서 첫 추억을 고를 수 있도록"))
        XCTAssertTrue(koreanInfoCopy.contains("최근 7일을 확인할 수 있어요"))
        XCTAssertTrue(koreanInfoCopy.contains("사진 고르기는 이 iPhone 안에서 이뤄져요"))
    }

    func testUserVisibleStringCatalogValuesDoNotContainCurationJargon() throws {
        let catalogURL = resourceURL("Weekkeep/Resources/Localizable.xcstrings")
        let catalogData = try Data(contentsOf: catalogURL)
        let catalog = try XCTUnwrap(JSONSerialization.jsonObject(with: catalogData) as? [String: Any])
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])
        let forbiddenTerms = ["초안", "draft"]

        for key in strings.keys.sorted() {
            let entry = try XCTUnwrap(strings[key] as? [String: Any], "Malformed catalog entry: \(key)")
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any], "Missing locales: \(key)")
            for locale in ["en", "ko"] {
                let localization = try XCTUnwrap(localizations[locale] as? [String: Any], "Missing \(locale) for \(key)")
                for value in stringUnitValues(in: localization) {
                    for forbiddenTerm in forbiddenTerms {
                        XCTAssertFalse(
                            value.localizedCaseInsensitiveContains(forbiddenTerm),
                            "User-visible \(locale) copy for \(key) contains forbidden term \(forbiddenTerm): \(value)"
                        )
                    }
                }
            }
        }
    }

    func testUserVisiblePrivacyCopyUsesPreciseProcessingAndSharingLanguage() throws {
        let catalogURL = resourceURL("Weekkeep/Resources/Localizable.xcstrings")
        let catalogData = try Data(contentsOf: catalogURL)
        let catalog = try XCTUnwrap(JSONSerialization.jsonObject(with: catalogData) as? [String: Any])
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])

        XCTAssertEqual(
            try catalogStringValue(strings, key: "onboarding.privacy", locale: "en"),
            "Photos are processed on your iPhone"
        )
        XCTAssertEqual(
            try catalogStringValue(strings, key: "onboarding.privacy", locale: "ko"),
            "사진 고르기는 이 iPhone 안에서 이뤄져요"
        )
        XCTAssertEqual(
            try catalogStringValue(strings, key: "privacy.body", locale: "en"),
            "Photo selection and share rendering are processed on your iPhone. Weekkeep does not send photos or photo details to analytics services or other services for analysis. Sharing starts only when you explicitly choose it."
        )
        XCTAssertEqual(
            try catalogStringValue(strings, key: "privacy.body", locale: "ko"),
            "사진 고르기와 공유 이미지 만들기는 이 iPhone에서 처리해요. 사진·미리보기·파일 이름·위치·촬영 시각 같은 사진 정보는 사용 통계나 다른 서비스의 분석을 위해 보내지 않아요. 공유는 직접 선택할 때만 시작돼요."
        )
        XCTAssertEqual(
            try catalogStringValue(strings, key: "privacy.youDecideBody", locale: "en"),
            "Sharing starts only when you explicitly choose it. You can change photo access any time in Settings."
        )
        XCTAssertEqual(
            try catalogStringValue(strings, key: "privacy.youDecideBody", locale: "ko"),
            "공유는 직접 선택할 때만 시작돼요. 사진 접근은 언제든 설정에서 바꿀 수 있어요."
        )

        let forbiddenPrivacyPhrases = [
            "photos stay on this iphone",
            "photos stay on this device",
            "photos never leave this iphone",
            "photos never leave the device",
            "사진은 이 iphone을 떠나",
            "사진은 기기를 떠나",
            "사진이 기기를 떠나",
            "사진은 이 iphone 안에서만",
            "사진 정보도 밖으로"
        ]
        for key in strings.keys.sorted() {
            let entry = try XCTUnwrap(strings[key] as? [String: Any], "Malformed catalog entry: \(key)")
            let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any], "Missing locales: \(key)")
            for locale in ["en", "ko"] {
                let localization = try XCTUnwrap(localizations[locale] as? [String: Any], "Missing \(locale) for \(key)")
                for value in stringUnitValues(in: localization) {
                    for forbiddenPhrase in forbiddenPrivacyPhrases {
                        XCTAssertFalse(
                            value.localizedCaseInsensitiveContains(forbiddenPhrase),
                            "User-visible \(locale) copy for \(key) contains disallowed privacy phrase \(forbiddenPhrase): \(value)"
                        )
                    }
                }
            }
        }
    }

    func testWeeklyStartCopyKeepsWelcomeAndRegularActionsDistinct() throws {
        let catalogURL = resourceURL("Weekkeep/Resources/Localizable.xcstrings")
        let catalogData = try Data(contentsOf: catalogURL)
        let catalog = try XCTUnwrap(JSONSerialization.jsonObject(with: catalogData) as? [String: Any])
        let strings = try XCTUnwrap(catalog["strings"] as? [String: Any])

        XCTAssertEqual(try catalogStringValue(strings, key: "week.makeWelcomeSelection", locale: "en"), "Choose your first week")
        XCTAssertEqual(try catalogStringValue(strings, key: "week.makeWelcomeSelection", locale: "ko"), "첫 주 추억 고르기")
        XCTAssertEqual(try catalogStringValue(strings, key: "week.makeDraft", locale: "en"), "Choose moments from last week")
        XCTAssertEqual(try catalogStringValue(strings, key: "week.makeDraft", locale: "ko"), "지난주 추억 고르기")
        XCTAssertNotEqual(
            try catalogStringValue(strings, key: "week.welcomeBody", locale: "en"),
            try catalogStringValue(strings, key: "week.readyBody", locale: "en")
        )
        XCTAssertNotEqual(
            try catalogStringValue(strings, key: "week.welcomeBody", locale: "ko"),
            try catalogStringValue(strings, key: "week.readyBody", locale: "ko")
        )
    }

    func testRuntimeCountAndViewerStringsForEnglishAndKorean() {
        let english = Locale(identifier: "en_US")
        let korean = Locale(identifier: "ko_KR")

        XCTAssertEqual(WeekkeepLocalization.string("week.photoCount", locale: english, 1), "1 photo from last week")
        XCTAssertEqual(WeekkeepLocalization.string("week.photoCount", locale: english, 2), "2 photos from last week")
        XCTAssertEqual(WeekkeepLocalization.string("week.photoCount", locale: korean, 1), "지난주 사진 1장")
        XCTAssertEqual(WeekkeepLocalization.string("week.photoCount", locale: korean, 2), "지난주 사진 2장")

        XCTAssertEqual(WeekkeepLocalization.string("review.body", locale: english, 1), "We found 1 moment to keep this week. Change it only if you want to.")
        XCTAssertEqual(WeekkeepLocalization.string("review.body", locale: english, 2), "We found 2 moments to keep this week. Change only what you want to.")
        XCTAssertEqual(WeekkeepLocalization.string("review.body", locale: korean, 1), "이번 주에 남길 순간 1장을 골라봤어요. 마음에 들지 않는 사진만 바꿔보세요.")
        XCTAssertEqual(WeekkeepLocalization.string("review.body", locale: korean, 2), "이번 주에 남길 순간 2장을 골라봤어요. 마음에 들지 않는 사진만 바꿔보세요.")

        XCTAssertEqual(WeekkeepLocalization.string("review.keep", locale: english, 1), "Save 1 photo")
        XCTAssertEqual(WeekkeepLocalization.string("review.keep", locale: english, 2), "Save 2 photos")
        XCTAssertEqual(WeekkeepLocalization.string("review.keep", locale: korean, 1), "사진 1장 남기기")
        XCTAssertEqual(WeekkeepLocalization.string("review.keep", locale: korean, 2), "사진 2장 남기기")

        for key in ["save.metadata", "detail.savedOnDevice"] {
            XCTAssertEqual(WeekkeepLocalization.string(key, locale: english, 1), "1 photo · Saved on this iPhone")
            XCTAssertEqual(WeekkeepLocalization.string(key, locale: english, 2), "2 photos · Saved on this iPhone")
            XCTAssertEqual(WeekkeepLocalization.string(key, locale: korean, 1), "사진 1장 · 이 iPhone에 저장됨")
            XCTAssertEqual(WeekkeepLocalization.string(key, locale: korean, 2), "사진 2장 · 이 iPhone에 저장됨")
        }

        XCTAssertEqual(WeekkeepLocalization.string("archive.photoCount", locale: english, 1), "1 photo")
        XCTAssertEqual(WeekkeepLocalization.string("archive.photoCount", locale: english, 2), "2 photos")
        XCTAssertEqual(WeekkeepLocalization.string("archive.photoCount", locale: korean, 1), "사진 1장")
        XCTAssertEqual(WeekkeepLocalization.string("archive.photoCount", locale: korean, 2), "사진 2장")

        XCTAssertEqual(WeekkeepLocalization.progress("review.bodyCount", completed: 1, total: 1, locale: english), "1 / 1 photo")
        XCTAssertEqual(WeekkeepLocalization.progress("review.bodyCount", completed: 1, total: 2, locale: english), "1 / 2 photos")
        XCTAssertEqual(WeekkeepLocalization.progress("review.bodyCount", completed: 1, total: 1, locale: korean), "사진 1 / 1장")
        XCTAssertEqual(WeekkeepLocalization.progress("review.bodyCount", completed: 1, total: 2, locale: korean), "사진 1 / 2장")

        XCTAssertEqual(WeekkeepLocalization.string("viewer.position", locale: english, 1, 7), "1 of 7")
        XCTAssertEqual(WeekkeepLocalization.string("viewer.position", locale: korean, 1, 7), "7장 중 1번째")
        XCTAssertEqual(WeekkeepLocalization.string("accessibility.photo", locale: english, 7, 1), "Photo 1 of 7")
        XCTAssertEqual(WeekkeepLocalization.string("accessibility.photo", locale: korean, 7, 1), "7장 중 1번째 사진")
    }

    func testProjectKeepsPhoneOnlyTargetingAndReleaseSigningAvailable() throws {
        let project = try String(contentsOf: resourceURL("project.yml"), encoding: .utf8)
        XCTAssertTrue(project.contains("TARGETED_DEVICE_FAMILY: \"1\""))
        XCTAssertTrue(project.contains("DEVELOPMENT_TEAM: D48DDX5D5W"))
        XCTAssertTrue(project.contains("CODE_SIGN_STYLE: Automatic"))
        XCTAssertFalse(project.contains("CODE_SIGN_IDENTITY: -"))
        XCTAssertFalse(project.contains("CODE_SIGNING_ALLOWED: NO"))
        XCTAssertFalse(project.contains("path: resources/fonts"))

        let release = try String(contentsOf: resourceURL("Config/Release.xcconfig"), encoding: .utf8)
        XCTAssertTrue(release.contains("WK_PURCHASES_ENABLED = YES"))
        XCTAssertTrue(release.contains("WK_ANALYTICS_ENABLED = NO"))

        let metadataData = try Data(contentsOf: resourceURL("release/app-store-metadata.json"))
        let metadata = try XCTUnwrap(JSONSerialization.jsonObject(with: metadataData) as? [String: Any])
        let app = try XCTUnwrap(metadata["app"] as? [String: Any])
        XCTAssertEqual(app["bundle_id"] as? String, "com.solkim.weekkeep")
        let iap = try XCTUnwrap(metadata["iap"] as? [String: Any])
        XCTAssertEqual(iap["product_id"] as? String, PurchaseContract.productID)
    }

    func testPublicLegalAndSupportLinksUseTheWeekkeepSite() {
        XCTAssertEqual(AppLinks.website.scheme, "https")
        XCTAssertEqual(AppLinks.website.host, "weekkeep-app.kimsol1134.chatgpt.site")
        XCTAssertEqual(AppLinks.privacy.path, "/privacy")
        XCTAssertEqual(AppLinks.terms.path, "/terms")
        XCTAssertEqual(AppLinks.support.path, "/support")
        XCTAssertEqual(AppLinks.contact.scheme, "mailto")
    }

    func testThirdPartyLicenseTextsAreVendored() throws {
        for name in ["LINESeedKR-OFL", "RevenueCat-LICENSE", "PostHog-LICENSE"] {
            let url = resourceURL("Weekkeep/Resources/Licenses/\(name).txt")
            let text = try String(contentsOf: url, encoding: .utf8)
            XCTAssertGreaterThan(text.count, 500, "\(name) must include the license text")
        }
    }

    private func resourceURL(_ relativePath: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent(relativePath)
    }

    private func localizedKeys(at url: URL) throws -> Set<String> {
        let contents = try String(contentsOf: url, encoding: .utf8)
        return Set(contents.split(separator: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.first == "\"" else { return nil }
            let remainder = trimmed.dropFirst()
            guard let end = remainder.firstIndex(of: "\"") else { return nil }
            return String(remainder[..<end])
        })
    }

    private func stringUnitValue(in localization: [String: Any]) -> String? {
        (localization["stringUnit"] as? [String: Any])?["value"] as? String
    }

    private func catalogStringValue(
        _ strings: [String: Any],
        key: String,
        locale: String
    ) throws -> String {
        let entry = try XCTUnwrap(strings[key] as? [String: Any])
        let localizations = try XCTUnwrap(entry["localizations"] as? [String: Any])
        let localization = try XCTUnwrap(localizations[locale] as? [String: Any])
        return try XCTUnwrap(stringUnitValue(in: localization))
    }

    private func stringUnitValues(in value: Any) -> [String] {
        if let dictionary = value as? [String: Any] {
            var values: [String] = []
            if let stringUnit = dictionary["stringUnit"] as? [String: Any],
               let stringValue = stringUnit["value"] as? String {
                values.append(stringValue)
            }
            for (key, nestedValue) in dictionary where key != "stringUnit" {
                values.append(contentsOf: stringUnitValues(in: nestedValue))
            }
            return values
        }
        if let array = value as? [Any] {
            return array.flatMap(stringUnitValues(in:))
        }
        return []
    }

    private func pluralVariants(in localization: [String: Any]) -> [String: Any] {
        if let direct = localization["variations"] as? [String: Any],
           let plural = direct["plural"] as? [String: Any] {
            return plural
        }
        let substitutions = localization["substitutions"] as? [String: Any]
        let total = substitutions?["total"] as? [String: Any]
        let variations = total?["variations"] as? [String: Any]
        return (variations?["plural"] as? [String: Any]) ?? [:]
    }

    private func pluralValues(_ plural: [String: Any]) throws -> [String] {
        try ["one", "other"].map { form in
            let variant = try XCTUnwrap(plural[form] as? [String: Any])
            return try XCTUnwrap(stringUnitValue(in: variant))
        }
    }
}
