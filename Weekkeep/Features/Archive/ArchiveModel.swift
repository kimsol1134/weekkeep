import Foundation
import Observation

@MainActor
@Observable
final class ArchiveModel {
    let environment: AppEnvironment
    var albums: [WeeklyAlbumSummary] = []
    var selectedAlbum: WeeklyAlbumSnapshot?
    var isLoading = false
    var error: String?

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let summaries = try await environment.albumStore.listAlbums()
            var resolved: [WeeklyAlbumSummary] = []
            resolved.reserveCapacity(summaries.count)
            for summary in summaries {
                guard let album = try await environment.albumStore.album(for: summary.weekKey) else {
                    resolved.append(summary)
                    continue
                }
                let availableIDs = await environment.photoLibrary.assetAvailability(
                    for: album.photos.map(\.assetLocalIdentifier)
                )
                resolved.append(WeeklyAlbumSummary(
                    id: summary.id,
                    weekKey: summary.weekKey,
                    kind: summary.kind,
                    weekStart: summary.weekStart,
                    weekEnd: summary.weekEnd,
                    createdAt: summary.createdAt,
                    photoCount: summary.photoCount,
                    availablePhotoCount: availableIDs.count,
                    coverPhotoID: summary.coverPhotoID
                ))
            }
            albums = resolved
        } catch {
            self.error = "archive.errorBody"
        }
    }

    func loadAlbum(weekKey: String) async {
        selectedAlbum = try? await environment.albumStore.album(for: weekKey)
    }

    func photoReference(from photo: AlbumPhotoSnapshot) -> PhotoReference {
        PhotoReference(
            id: photo.assetLocalIdentifier,
            capturedAt: photo.capturedAt ?? Date.distantPast,
            pixelWidth: 1_200,
            pixelHeight: 1_600,
            score: photo.scoreSnapshot ?? 0.5,
            source: photo.source
        )
    }
}
