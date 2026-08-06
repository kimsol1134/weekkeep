import Foundation
import Dispatch
import ImageIO
import Vision

enum CurationProgressStage: String, Sendable, Equatable {
    case fetchingAssets
    case prefiltering
    case downloadingFromICloud
    case analyzing
    case deduplicating
    case ranking
}

struct CurationProgress: Sendable, Equatable {
    let stage: CurationProgressStage
    let completed: Int
    let total: Int
    let skippedCount: Int
    /// The cumulative candidate request work resolved, including assets
    /// skipped by a timeout or the global budget. PhotoKit does not expose
    /// byte-level callbacks through the adapter, so this is deliberately an
    /// orchestration-level request count rather than an iCloud byte estimate.
    let overallCompleted: Int
    let overallTotal: Int

    init(
        stage: CurationProgressStage,
        completed: Int,
        total: Int,
        skippedCount: Int,
        overallCompleted: Int? = nil,
        overallTotal: Int? = nil
    ) {
        self.stage = stage
        self.completed = completed
        self.total = total
        self.skippedCount = skippedCount
        self.overallCompleted = overallCompleted ?? min(max(completed + skippedCount, 0), max(total, 0))
        self.overallTotal = overallTotal ?? max(total, 0)
    }
}

protocol PhotoAnalysisService: Sendable {
    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft
}

struct CurationAnalysisBudget: Sendable, Equatable {
    static let v1 = CurationAnalysisBudget(
        descriptorScanLimit: MetadataCandidatePrefilter.descriptorScanLimit,
        maximumVisionCandidates: MetadataCandidatePrefilter.maximumVisionCandidates,
        analysisPixelSize: 416,
        perAssetTimeoutNanoseconds: 1_500_000_000,
        globalTimeoutNanoseconds: 12_000_000_000
    )

    let descriptorScanLimit: Int
    let maximumVisionCandidates: Int
    let analysisPixelSize: Int
    let perAssetTimeoutNanoseconds: UInt64
    let globalTimeoutNanoseconds: UInt64

    init(
        descriptorScanLimit: Int,
        maximumVisionCandidates: Int,
        analysisPixelSize: Int,
        perAssetTimeoutNanoseconds: UInt64,
        globalTimeoutNanoseconds: UInt64
    ) {
        self.descriptorScanLimit = min(max(descriptorScanLimit, 1), MetadataCandidatePrefilter.descriptorScanLimit)
        self.maximumVisionCandidates = min(max(maximumVisionCandidates, 1), MetadataCandidatePrefilter.maximumVisionCandidates)
        self.analysisPixelSize = min(max(analysisPixelSize, 384), 448)
        self.perAssetTimeoutNanoseconds = max(1, perAssetTimeoutNanoseconds)
        self.globalTimeoutNanoseconds = max(1, globalTimeoutNanoseconds)
    }
}

enum CurationAnalysisTimeout: Error, Sendable, Equatable {
    case asset
    case globalBudget
}

protocol PhotoAnalysisClock: Sendable {
    func nowNanoseconds() -> UInt64
}

struct SystemPhotoAnalysisClock: PhotoAnalysisClock, Sendable {
    func nowNanoseconds() -> UInt64 { DispatchTime.now().uptimeNanoseconds }
}

protocol PhotoSignalAnalyzer: Sendable {
    func beginAnalysisSession() async
    func analyze(imageData: Data, photoID: PhotoID) async throws -> VisionSignals
}

extension PhotoSignalAnalyzer {
    func beginAnalysisSession() async {}
}

actor OnDevicePhotoAnalysisPipeline: PhotoAnalysisService {
    private let photoLibrary: any PhotoLibraryClient
    private let sampler: CandidateSampler
    private let engine: CurationEngine
    private let analyzer: any PhotoSignalAnalyzer
    private let budget: CurationAnalysisBudget
    private let clock: any PhotoAnalysisClock

    init(
        photoLibrary: any PhotoLibraryClient,
        sampler: CandidateSampler? = nil,
        analyzer: any PhotoSignalAnalyzer = VisionPhotoAnalyzer(),
        budget: CurationAnalysisBudget = .v1,
        clock: any PhotoAnalysisClock = SystemPhotoAnalysisClock(),
        timeZoneIdentifier: String = TimeZone.current.identifier
    ) {
        self.photoLibrary = photoLibrary
        self.budget = budget
        let requestedSampler = sampler ?? CandidateSampler(
            maximumCount: budget.maximumVisionCandidates,
            timeZoneIdentifier: timeZoneIdentifier
        )
        self.sampler = CandidateSampler(
            maximumCount: min(requestedSampler.maximumCount, budget.maximumVisionCandidates),
            timeBucketHours: requestedSampler.timeBucketHours,
            timeZoneIdentifier: requestedSampler.timeZoneIdentifier
        )
        self.engine = CurationEngine(
            sampler: self.sampler,
            timeZoneIdentifier: timeZoneIdentifier
        )
        self.analyzer = analyzer
        self.clock = clock
    }

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft {
        progress(CurationProgress(stage: .fetchingAssets, completed: 0, total: 0, skippedCount: 0))
        let range = DateInterval(start: week.start, end: week.end)
        let descriptors = try await photoLibrary.fetchDescriptors(in: range, limit: budget.descriptorScanLimit)
        let sampled = sampler.sample(descriptors, weekKey: week.key)
        let total = sampled.count
        progress(CurationProgress(
            stage: .prefiltering,
            completed: descriptors.count,
            total: descriptors.count,
            skippedCount: 0,
            overallCompleted: 0,
            overallTotal: total
        ))
        progress(CurationProgress(
            stage: .downloadingFromICloud,
            completed: 0,
            total: total,
            skippedCount: 0,
            overallCompleted: 0,
            overallTotal: total
        ))

        var candidates: [PhotoCandidate] = []
        var skippedCount = 0
        var requestProgress = PhotoRequestProgressAggregator(total: total)
        defer {
            if Task.isCancelled {
                requestProgress.cancel()
            }
        }
        candidates.reserveCapacity(min(sampled.count, budget.maximumVisionCandidates))
        await analyzer.beginAnalysisSession()
        let startedAt = clock.nowNanoseconds()
        let deadline = startedAt &+ budget.globalTimeoutNanoseconds
        for (index, descriptor) in sampled.enumerated() {
            try Task.checkCancellation()
            let now = clock.nowNanoseconds()
            guard now < deadline else {
                skippedCount += sampled.count - index
                requestProgress.completeRemainingRequests()
                progress(CurationProgress(
                    stage: .analyzing,
                    completed: index,
                    total: total,
                    skippedCount: skippedCount,
                    overallCompleted: requestProgress.progress.completed,
                    overallTotal: requestProgress.progress.total
                ))
                break
            }
            let remainingBudget = deadline - now
            let timeout = min(budget.perAssetTimeoutNanoseconds, remainingBudget)
            do {
                let signals = try await withTimeout(nanoseconds: timeout) { [self] in
                    let image = try await photoLibrary.analysisImage(
                        for: descriptor.id,
                        targetSize: CGSize(width: budget.analysisPixelSize, height: budget.analysisPixelSize)
                    )
                    return try await analyzer.analyze(imageData: image.data, photoID: descriptor.id)
                }
                guard !signals.isUtility else {
                    skippedCount += 1
                    requestProgress.completeRequest()
                    progress(CurationProgress(
                        stage: .analyzing,
                        completed: index + 1,
                        total: total,
                        skippedCount: skippedCount,
                        overallCompleted: requestProgress.progress.completed,
                        overallTotal: requestProgress.progress.total
                    ))
                    continue
                }
                candidates.append(PhotoCandidate(
                    descriptor: descriptor,
                    aestheticsScore: signals.aestheticsScore,
                    technicalScore: signals.technicalScore,
                    faceCompositionScore: signals.faceCompositionScore,
                    duplicateGroup: signals.duplicateGroup
                ))
            } catch is CancellationError {
                throw CancellationError()
            } catch CurationAnalysisTimeout.asset {
                skippedCount += 1
            } catch {
                skippedCount += 1
            }
            requestProgress.completeRequest()
            progress(CurationProgress(
                stage: .analyzing,
                completed: index + 1,
                total: total,
                skippedCount: skippedCount,
                overallCompleted: requestProgress.progress.completed,
                overallTotal: requestProgress.progress.total
            ))
        }

        guard !candidates.isEmpty else { throw WeekkeepError.analysis }
        progress(CurationProgress(
            stage: .deduplicating,
            completed: total,
            total: total,
            skippedCount: skippedCount,
            overallCompleted: requestProgress.progress.completed,
            overallTotal: requestProgress.progress.total
        ))
        progress(CurationProgress(
            stage: .ranking,
            completed: total,
            total: total,
            skippedCount: skippedCount,
            overallCompleted: requestProgress.progress.completed,
            overallTotal: requestProgress.progress.total
        ))
        return try engine.makeDraft(
            kind: kind,
            week: week,
            analysisCutoff: analysisCutoff,
            descriptors: sampled,
            candidates: candidates,
            skippedAssetCount: skippedCount
        )
    }

    private func withTimeout<T: Sendable>(
        nanoseconds: UInt64,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask(operation: operation)
            group.addTask {
                try await Task.sleep(nanoseconds: nanoseconds)
                throw CurationAnalysisTimeout.asset
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else {
                throw CurationAnalysisTimeout.asset
            }
            return result
        }
    }
}

struct VisionSignals: Sendable, Equatable {
    let aestheticsScore: Double
    let isUtility: Bool
    let technicalScore: Double
    let faceCompositionScore: Double?
    let duplicateGroup: String?
}

enum VisionAnalysisError: Error, Sendable {
    case invalidImage
}

actor VisionPhotoAnalyzer: PhotoSignalAnalyzer {
    private var featurePrints: [(group: String, observation: VNFeaturePrintObservation)] = []

    func beginAnalysisSession() async {
        // Duplicate groups are meaningful only within one weekly shortlist.
        // Resetting here also keeps comparison work bounded across app use.
        featurePrints.removeAll(keepingCapacity: true)
    }

    func analyze(imageData: Data, photoID: PhotoID) async throws -> VisionSignals {
        guard CGImageSourceCreateWithData(imageData as CFData, nil) != nil else {
            throw VisionAnalysisError.invalidImage
        }

        let faceRequest = VNDetectFaceRectanglesRequest()
        let featureRequest = VNGenerateImageFeaturePrintRequest()
        // Vision can temporarily be unavailable on a simulator or while a
        // device model is warming up. Treat each signal independently so one
        // unavailable observation does not erase an otherwise valid week.
        let sharedHandler = VNImageRequestHandler(data: imageData, options: [:])
        _ = try? sharedHandler.perform([faceRequest, featureRequest])

        let faces = faceRequest.results ?? []
        let faceCount = faces.count
        let faceCompositionScore: Double? = faceCount > 0 ? min(0.55 + (Double(faceCount) * 0.08), 0.95) : nil
        let group = duplicateGroup(for: featureRequest.results?.first as? VNFeaturePrintObservation)
        let technicalScore = technicalScore(for: imageData)
        let aesthetics = await aestheticsSignal(for: imageData, faceCount: faceCount)
        return VisionSignals(
            aestheticsScore: aesthetics.score,
            isUtility: aesthetics.isUtility,
            technicalScore: technicalScore,
            faceCompositionScore: faceCompositionScore,
            duplicateGroup: group
        )
    }

    private struct AestheticsSignal: Sendable {
        let score: Double
        let isUtility: Bool
    }

    private func aestheticsSignal(for imageData: Data, faceCount: Int) async -> AestheticsSignal {
        // iOS 18's async Vision request is the primary source of the ranking
        // signal. It returns Apple's overall score in [-1, 1], while the
        // curation engine consumes the normalized [0, 1] form.
        if let observation = try? await CalculateImageAestheticsScoresRequest().perform(on: imageData) {
            return AestheticsSignal(
                score: normalizedAestheticsScore(observation.overallScore),
                isUtility: observation.isUtility
            )
        }

        // Keep a real Vision fallback for devices where the async request is
        // temporarily unavailable (for example, a model warm-up failure).
        // A single image failure should not discard the entire weekly draft.
        let request = VNCalculateImageAestheticsScoresRequest()
        let fallbackHandler = VNImageRequestHandler(data: imageData, options: [:])
        if (try? fallbackHandler.perform([request])) != nil,
           let observation = request.results?.first {
            return AestheticsSignal(
                score: normalizedAestheticsScore(observation.overallScore),
                isUtility: observation.isUtility
            )
        }

        // Face presence is only a deterministic last-resort prior. It is not
        // a claim that Weekkeep identifies a child or family member.
        return AestheticsSignal(score: faceCount > 0 ? 0.78 : 0.68, isUtility: false)
    }

    private func normalizedAestheticsScore(_ score: Float) -> Double {
        let clamped = min(max(Double(score), -1), 1)
        return (clamped + 1) / 2
    }

    private func technicalScore(for imageData: Data) -> Double {
        let contrast = imageContrastScore(for: imageData)
        // Keep technical usability as a modest, deterministic signal. Face
        // capture quality used to trigger a second Vision image pass; the
        // shared face request plus contrast preserves the utility intent at a
        // lower cost without making a claim about who is in the photo.
        return min(max(0.70 + (0.30 * contrast), 0), 1)
    }

    private func imageContrastScore(for imageData: Data) -> Double {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return 0.72
        }

        let width = 32
        let height = 32
        var pixels = [UInt8](repeating: 0, count: width * height)
        let contrast: Double = pixels.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            ) else {
                return 0.72
            }
            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

            let values = buffer.bindMemory(to: UInt8.self)
            let mean = values.reduce(0.0) { $0 + Double($1) } / Double(values.count)
            let variance = values.reduce(0.0) { partial, value in
                let difference = Double(value) - mean
                return partial + (difference * difference)
            } / Double(values.count)
            let standardDeviation = sqrt(variance) / 255
            return min(max(standardDeviation / 0.25, 0.35), 1)
        }
        return contrast
    }

    private func duplicateGroup(for observation: VNFeaturePrintObservation?) -> String? {
        guard let observation else { return nil }
        for existing in featurePrints {
            var distance = Float.zero
            if (try? observation.computeDistance(&distance, to: existing.observation)) != nil, distance < 0.18 {
                return existing.group
            }
        }
        let group = "group-\(featurePrints.count + 1)"
        featurePrints.append((group, observation))
        return group
    }
}
