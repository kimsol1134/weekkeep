import Foundation
import UIKit

#if DEBUG
enum AppStoreScreenshotFixtureError: Error, Sendable {
    case expectedSevenFixtures(found: Int)
}

/// Deterministic foreground analysis for App Store screenshot capture. It
/// consumes the bundled `SamplePhotoFixtures` through the fixture photo
/// adapter, uses stable descriptor order and fixed scores rather than Vision,
/// and never exercises simulator PhotoKit ingestion.
actor AppStoreScreenshotFixtureAnalysisService: PhotoAnalysisService {
    private let photoLibrary: any PhotoLibraryClient

    init(photoLibrary: any PhotoLibraryClient) {
        self.photoLibrary = photoLibrary
    }

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft {
        let range = DateInterval(start: week.start, end: week.end)
        let descriptors = try await photoLibrary
            .fetchDescriptors(in: range, limit: 100)
            .filter(\.isEligible)
            .sorted {
                if $0.capturedAt != $1.capturedAt { return $0.capturedAt < $1.capturedAt }
                return $0.id.rawValue < $1.id.rawValue
            }

        guard descriptors.count == 7 else {
            throw AppStoreScreenshotFixtureError.expectedSevenFixtures(found: descriptors.count)
        }

        progress(CurationProgress(stage: .fetchingAssets, completed: 0, total: descriptors.count, skippedCount: 0))
        progress(CurationProgress(stage: .fetchingAssets, completed: descriptors.count, total: descriptors.count, skippedCount: 0))
        progress(CurationProgress(stage: .analyzing, completed: 0, total: descriptors.count, skippedCount: 0))

        // Keep the progress screen visible long enough for a screenshot test
        // to observe the real foreground waiting state.
        try await Task.sleep(nanoseconds: 6_000_000_000)

        var candidates: [PhotoCandidate] = []
        candidates.reserveCapacity(descriptors.count)
        for (index, descriptor) in descriptors.enumerated() {
            try Task.checkCancellation()
            _ = try await photoLibrary.analysisImage(
                for: descriptor.id,
                targetSize: CGSize(width: 640, height: 640)
            )
            candidates.append(PhotoCandidate(
                descriptor: descriptor,
                aestheticsScore: 0.96 - (Double(index) * 0.01),
                technicalScore: 0.86,
                faceCompositionScore: nil,
                duplicateGroup: nil
            ))
            progress(CurationProgress(
                stage: .analyzing,
                completed: index + 1,
                total: descriptors.count,
                skippedCount: 0
            ))
        }

        progress(CurationProgress(stage: .deduplicating, completed: candidates.count, total: candidates.count, skippedCount: 0))
        progress(CurationProgress(stage: .ranking, completed: candidates.count, total: candidates.count, skippedCount: 0))
        return try CurationEngine().makeDraft(
            kind: kind,
            week: week,
            analysisCutoff: analysisCutoff,
            descriptors: descriptors,
            candidates: candidates
        )
    }
}
#endif

#if DEBUG
actor FixturePhotoLibraryClient: PhotoLibraryClient {
    private let descriptors: [PhotoDescriptor]
    private var permission: PhotoAuthorization

    init(descriptors: [PhotoDescriptor] = FixturePhotoLibraryClient.makeDescriptors(count: 42), permission: PhotoAuthorization = .authorized) {
        self.descriptors = descriptors
        self.permission = permission
    }

    func authorizationStatus() async -> PhotoAuthorization { permission }

    func requestAuthorization() async -> PhotoAuthorization {
        if permission == .notDetermined { permission = .authorized }
        return permission
    }

    func fetchDescriptors(in range: DateInterval, limit: Int) async throws -> [PhotoDescriptor] {
        guard permission == .authorized || permission == .limited else { throw PhotoAccessChangedError() }
        return Array(descriptors.filter { range.contains($0.capturedAt) }.prefix(limit))
    }

    func analysisImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        try makeImage(for: id, targetSize: targetSize)
    }

    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        try makeImage(for: id, targetSize: targetSize)
    }

    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID> {
        Set(ids.filter { id in descriptors.contains { $0.id == id } })
    }

    func setPermission(_ permission: PhotoAuthorization) { self.permission = permission }

    private func makeImage(for id: PhotoID, targetSize: CGSize) throws -> PhotoImageData {
        if id.rawValue.hasPrefix("fixture-photo-"),
           let fixtureIndex = Int(id.rawValue.split(separator: "-").last ?? ""),
           let fixtureImage = UIImage(named: SamplePhotoFixtures.assetName(for: fixtureIndex % SamplePhotoFixtures.assetNames.count)),
           let fixtureData = fixtureImage.jpegData(compressionQuality: 0.9) {
            return PhotoImageData(
                data: fixtureData,
                pixelWidth: Int(fixtureImage.size.width * fixtureImage.scale),
                pixelHeight: Int(fixtureImage.size.height * fixtureImage.scale)
            )
        }

        // Keep every debug photo path inside the same approved fixture
        // vocabulary; synthetic gradients must never masquerade as photos.
        let seed = id.rawValue.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }
        let fixtureName = SamplePhotoFixtures.assetName(for: abs(seed) % SamplePhotoFixtures.assetNames.count)
        guard let fixtureImage = UIImage(named: fixtureName),
              let fixtureData = fixtureImage.jpegData(compressionQuality: 0.9) else {
            throw PhotoAccessChangedError()
        }
        return PhotoImageData(
            data: fixtureData,
            pixelWidth: Int(fixtureImage.size.width * fixtureImage.scale),
            pixelHeight: Int(fixtureImage.size.height * fixtureImage.scale)
        )
    }

    static func makeDescriptors(count: Int, baseDate: Date = Date()) -> [PhotoDescriptor] {
        let start = baseDate.addingTimeInterval(-6 * 24 * 60 * 60)
        return (0..<count).map { index in
            PhotoDescriptor(
                id: PhotoID("fixture-photo-\(index)"),
                capturedAt: start.addingTimeInterval(Double(index) * 3_600),
                pixelWidth: 1_200 + (index % 4) * 200,
                pixelHeight: 1_600 + (index % 3) * 120,
                isFavorite: index % 11 == 0,
                isHidden: false,
                isScreenshot: false
            )
        }
    }
}

actor FixturePhotoAnalysisService: PhotoAnalysisService {
    private let photoLibrary: any PhotoLibraryClient
    private let engine = CurationEngine()

    init(photoLibrary: any PhotoLibraryClient) {
        self.photoLibrary = photoLibrary
    }

    func makeDraft(
        kind: AlbumKind,
        week: WeekRange,
        analysisCutoff: Date,
        progress: @escaping @Sendable (CurationProgress) -> Void
    ) async throws -> CurationDraft {
        let descriptors = try await photoLibrary.fetchDescriptors(in: DateInterval(start: week.start, end: week.end), limit: 500)
        progress(CurationProgress(stage: .fetchingAssets, completed: descriptors.count, total: descriptors.count, skippedCount: 0))
        let candidates = descriptors.enumerated().map { index, descriptor in
            PhotoCandidate(
                descriptor: descriptor,
                aestheticsScore: 0.56 + Double((index * 7) % 35) / 100,
                technicalScore: 0.76 + Double(index % 5) / 20,
                faceCompositionScore: index % 4 == 0 ? 0.78 : nil,
                duplicateGroup: index % 6 == 0 ? "fixture-group-\(index / 6)" : nil
            )
        }
        progress(CurationProgress(stage: .analyzing, completed: descriptors.count, total: descriptors.count, skippedCount: 0))
#if DEBUG
        if ProcessInfo.processInfo.environment["WK_CAPTURE_REMOTION_FOOTAGE"] == "1" {
            // The opt-in footage path needs a short, honest foreground wait so
            // the real curation screen is visible in the raw screen recording.
            // Ordinary fixture tests never set this environment value.
            try await Task.sleep(nanoseconds: 1_500_000_000)
        }
#endif
        return try engine.makeDraft(
            kind: kind,
            week: week,
            analysisCutoff: analysisCutoff,
            descriptors: descriptors,
            candidates: candidates
        )
    }
}
#endif
