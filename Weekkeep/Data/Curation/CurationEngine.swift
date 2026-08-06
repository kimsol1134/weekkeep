import Foundation

struct PhotoCandidate: Sendable, Equatable, Hashable {
    let descriptor: PhotoDescriptor
    let aestheticsScore: Double
    let technicalScore: Double
    let faceCompositionScore: Double?
    let duplicateGroup: String?

    var baseScore: Double {
        let faceScore = faceCompositionScore ?? 0.5
        let favoritePrior = descriptor.isFavorite ? 0.05 : 0
        return (0.50 * aestheticsScore)
            + (0.20 * faceScore)
            + (0.15 * technicalScore)
            + (0.10 * resolutionFitness)
            + favoritePrior
    }

    private var resolutionFitness: Double {
        let pixels = Double(descriptor.pixelWidth * descriptor.pixelHeight)
        return min(max(pixels / 4_000_000, 0), 1)
    }
}

/// Cheap, deterministic metadata policy used before any Vision work.
///
/// The descriptor scan may be larger, but this policy is the explicit contract
/// that bounds ranking images sent to Vision. Calendar-day and time-bucket
/// coverage are structural priorities; favorite and resolution are only
/// tie-breakers inside a covered bucket.
struct MetadataCandidatePrefilter: Sendable, Equatable {
    static let descriptorScanLimit = 500
    /// Three candidates per calendar day keeps the seven-day story diverse
    /// while bounding foreground Vision work to a parent-friendly wait.
    static let maximumVisionCandidates = 21

    let maximumCount: Int
    let timeBucketHours: Int
    let timeZoneIdentifier: String

    init(
        maximumCount: Int = Self.maximumVisionCandidates,
        timeBucketHours: Int = 4,
        timeZoneIdentifier: String = TimeZone.current.identifier
    ) {
        self.maximumCount = min(max(maximumCount, 0), Self.maximumVisionCandidates)
        self.timeBucketHours = min(max(timeBucketHours, 1), 24)
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    func sample(_ descriptors: [PhotoDescriptor], weekKey: String) -> [PhotoDescriptor] {
        let eligible = descriptors
            .filter(\.isEligible)
            .sorted(by: chronologicalOrder)
        guard eligible.count > maximumCount else { return eligible }
        guard maximumCount > 0 else { return [] }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current

        let groupedByDay = Dictionary(grouping: eligible) { descriptor in
            calendar.startOfDay(for: descriptor.capturedAt)
        }
        let dayKeys = groupedByDay.keys.sorted()
        let dayQueues = dayKeys.map { day in
            queue(for: groupedByDay[day] ?? [], calendar: calendar)
        }

        var selected: [PhotoDescriptor] = []
        var nextIndexByDay = Array(repeating: 0, count: dayQueues.count)
        let startOffset = stableSeed(for: weekKey) % max(dayQueues.count, 1)

        while selected.count < maximumCount {
            var madeProgress = false
            for offset in 0..<dayQueues.count {
                let dayIndex = (startOffset + offset) % dayQueues.count
                guard nextIndexByDay[dayIndex] < dayQueues[dayIndex].count else { continue }
                selected.append(dayQueues[dayIndex][nextIndexByDay[dayIndex]])
                nextIndexByDay[dayIndex] += 1
                madeProgress = true
                if selected.count == maximumCount { break }
            }
            guard madeProgress else { break }
        }

        return selected.sorted(by: chronologicalOrder)
    }

    private func queue(for descriptors: [PhotoDescriptor], calendar: Calendar) -> [PhotoDescriptor] {
        let groupedByTimeBucket = Dictionary(grouping: descriptors) { descriptor in
            calendar.component(.hour, from: descriptor.capturedAt) / timeBucketHours
        }

        let bucketQueues = groupedByTimeBucket.keys.sorted().map { bucket in
            (groupedByTimeBucket[bucket] ?? []).sorted(by: metadataTieBreakOrder)
        }
        var nextIndexByBucket = Array(repeating: 0, count: bucketQueues.count)
        var result: [PhotoDescriptor] = []

        // Interleave time buckets inside each day. Flattening whole buckets
        // would let a busy morning consume the cap before afternoon/evening
        // moments were considered.
        while true {
            var madeProgress = false
            for bucketIndex in bucketQueues.indices {
                guard nextIndexByBucket[bucketIndex] < bucketQueues[bucketIndex].count else { continue }
                result.append(bucketQueues[bucketIndex][nextIndexByBucket[bucketIndex]])
                nextIndexByBucket[bucketIndex] += 1
                madeProgress = true
            }
            guard madeProgress else { return result }
        }
    }

    private func metadataTieBreakOrder(_ lhs: PhotoDescriptor, _ rhs: PhotoDescriptor) -> Bool {
        if lhs.isFavorite != rhs.isFavorite { return lhs.isFavorite }
        let lhsPixels = Double(lhs.pixelWidth) * Double(lhs.pixelHeight)
        let rhsPixels = Double(rhs.pixelWidth) * Double(rhs.pixelHeight)
        if lhsPixels != rhsPixels { return lhsPixels > rhsPixels }
        return chronologicalOrder(lhs, rhs)
    }

    private func chronologicalOrder(_ lhs: PhotoDescriptor, _ rhs: PhotoDescriptor) -> Bool {
        if lhs.capturedAt != rhs.capturedAt { return lhs.capturedAt < rhs.capturedAt }
        return lhs.id.rawValue < rhs.id.rawValue
    }

    private func stableSeed(for string: String) -> Int {
        string.utf8.reduce(17) { ($0 &* 31) &+ Int($1) } & 0x7fff_ffff
    }
}

typealias CandidateSampler = MetadataCandidatePrefilter

struct CurationEngine: Sendable {
    let sampler: CandidateSampler
    let timeZoneIdentifier: String

    init(
        sampler: CandidateSampler = CandidateSampler(),
        timeZoneIdentifier: String = TimeZone.current.identifier
    ) {
        self.sampler = sampler
        self.timeZoneIdentifier = timeZoneIdentifier
    }

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        descriptors: [PhotoDescriptor],
        candidates: [PhotoCandidate],
        skippedAssetCount: Int = 0
    ) throws -> CurationDraft {
        let sampledIDs = Set(sampler.sample(descriptors, weekKey: week.key).map(\.id))
        let filtered = candidates
            .filter { sampledIDs.contains($0.descriptor.id) && $0.descriptor.isEligible }
            .map { candidate in
                PhotoReference(
                    id: candidate.descriptor.id,
                    capturedAt: candidate.descriptor.capturedAt,
                    pixelWidth: candidate.descriptor.pixelWidth,
                    pixelHeight: candidate.descriptor.pixelHeight,
                    score: candidate.baseScore,
                    source: .initial
                )
            }
            .sorted {
                if $0.score != $1.score { return $0.score > $1.score }
                return $0.id.rawValue < $1.id.rawValue
            }

        let selectedCount = min(filtered.count, 7)
        var selected: [PhotoReference] = []
        var remaining = filtered
        var selectedGroups = Set<String>()
        var selectedDays = Set<String>()
        var selectedTimeBuckets = Set<Int>()

        while selected.count < selectedCount, !remaining.isEmpty {
            let bestIndex = remaining.indices.max { lhs, rhs in
                value(of: remaining[lhs], selectedGroups: selectedGroups, selectedDays: selectedDays, selectedTimeBuckets: selectedTimeBuckets, candidates: candidates)
                    < value(of: remaining[rhs], selectedGroups: selectedGroups, selectedDays: selectedDays, selectedTimeBuckets: selectedTimeBuckets, candidates: candidates)
            } ?? remaining.startIndex
            let choice = remaining.remove(at: bestIndex)
            selected.append(choice)
            if let group = duplicateGroup(for: choice, candidates: candidates) { selectedGroups.insert(group) }
            selectedDays.insert(dayBucket(for: choice.capturedAt))
            selectedTimeBuckets.insert(timeBucket(for: choice.capturedAt))
        }

        selected.sort(by: referenceOrder)
        let rankedRemaining = remaining.sorted(by: alternativeOrder)
        var alternativeReferences: [PhotoReference] = []
        var remainingForAlternatives = rankedRemaining

        // Preserve one strong unused alternative for each selected local day
        // before filling the bounded shortlist by overall score.
        let selectedDayKeys = Set(selected.map { dayKey(for: $0.capturedAt) }).sorted()
        for dayKeyValue in selectedDayKeys {
            guard let index = remainingForAlternatives.firstIndex(where: { dayKey(for: $0.capturedAt) == dayKeyValue }) else {
                continue
            }
            alternativeReferences.append(remainingForAlternatives.remove(at: index))
        }
        alternativeReferences.append(contentsOf: remainingForAlternatives)

        let alternatives = alternativeReferences
            .prefix(7)
            .map { reference in
                var copy = reference
                copy.source = .replacement
                return copy
            }

        let draft = CurationDraft(
            id: UUID(),
            kind: kind,
            week: week,
            analysisCutoff: analysisCutoff,
            selected: selected,
            alternatives: Array(alternatives),
            replacementCount: 0,
            skippedAssetCount: skippedAssetCount
        )
        return try draft.validated()
    }

    private func value(
        of photo: PhotoReference,
        selectedGroups: Set<String>,
        selectedDays: Set<String>,
        selectedTimeBuckets: Set<Int>,
        candidates: [PhotoCandidate]
    ) -> Double {
        let dayBonus = selectedDays.contains(dayBucket(for: photo.capturedAt)) ? 0 : 0.08
        let timeBonus = selectedTimeBuckets.contains(timeBucket(for: photo.capturedAt)) ? 0 : 0.06
        let duplicatePenalty: Double = {
            guard let group = duplicateGroup(for: photo, candidates: candidates) else { return 0 }
            return selectedGroups.contains(group) ? 0.4 : 0
        }()
        return photo.score + dayBonus + timeBonus - duplicatePenalty
    }

    private func duplicateGroup(for photo: PhotoReference, candidates: [PhotoCandidate]) -> String? {
        candidates.first(where: { $0.descriptor.id == photo.id })?.duplicateGroup
    }

    private func dayKey(for date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    private func dayBucket(for date: Date) -> String {
        dayKey(for: date)
    }

    private func timeBucket(for date: Date) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        return calendar.component(.hour, from: date) / 4
    }

    private func alternativeOrder(_ lhs: PhotoReference, _ rhs: PhotoReference) -> Bool {
        if lhs.score != rhs.score { return lhs.score > rhs.score }
        if lhs.capturedAt != rhs.capturedAt { return lhs.capturedAt < rhs.capturedAt }
        return lhs.id.rawValue < rhs.id.rawValue
    }

    private func referenceOrder(_ lhs: PhotoReference, _ rhs: PhotoReference) -> Bool {
        if lhs.capturedAt != rhs.capturedAt { return lhs.capturedAt < rhs.capturedAt }
        return lhs.id.rawValue < rhs.id.rawValue
    }
}
