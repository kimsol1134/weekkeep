import Foundation
import SwiftData

@Model
final class WeeklyAlbumEntity {
    @Attribute(.unique) var weekKey: String
    var id: UUID
    var kindRaw: String
    var weekStart: Date
    var weekEnd: Date
    var analysisCutoff: Date
    var createdAt: Date
    var updatedAt: Date
    var coverPhotoID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \AlbumPhotoEntity.album)
    var photos: [AlbumPhotoEntity] = []

    init(
        id: UUID,
        weekKey: String,
        kind: AlbumKind,
        weekStart: Date,
        weekEnd: Date,
        analysisCutoff: Date,
        createdAt: Date,
        updatedAt: Date,
        coverPhotoID: UUID?
    ) {
        self.id = id
        self.weekKey = weekKey
        self.kindRaw = kind.rawValue
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.analysisCutoff = analysisCutoff
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.coverPhotoID = coverPhotoID
    }

    var kind: AlbumKind { AlbumKind(rawValue: kindRaw) ?? .regular }
}

@Model
final class AlbumPhotoEntity {
    var id: UUID
    var assetLocalIdentifier: String
    var capturedAt: Date?
    var position: Int
    var sourceRaw: String
    var scoreSnapshot: Double?
    var album: WeeklyAlbumEntity?

    init(
        id: UUID,
        assetLocalIdentifier: String,
        capturedAt: Date?,
        position: Int,
        source: PhotoSource,
        scoreSnapshot: Double?
    ) {
        self.id = id
        self.assetLocalIdentifier = assetLocalIdentifier
        self.capturedAt = capturedAt
        self.position = position
        self.sourceRaw = source.rawValue
        self.scoreSnapshot = scoreSnapshot
    }

    var source: PhotoSource { PhotoSource(rawValue: sourceRaw) ?? .initial }
}

private enum AlbumStoreOrdering {
    static func chronological(_ lhs: PhotoReference, _ rhs: PhotoReference) -> Bool {
        if lhs.capturedAt != rhs.capturedAt {
            return lhs.capturedAt < rhs.capturedAt
        }
        return lhs.id.rawValue < rhs.id.rawValue
    }

    static func bestCoverIndex<T>(
        in values: [T],
        qualityScore: (T) -> Double?,
        stableIdentity: (T) -> String
    ) -> Int? {
        guard let firstIndex = values.indices.first else { return nil }

        return values.indices.dropFirst().reduce(firstIndex) { currentIndex, candidateIndex in
            let currentScore = comparableScore(qualityScore(values[currentIndex]))
            let candidateScore = comparableScore(qualityScore(values[candidateIndex]))

            if candidateScore != currentScore {
                return candidateScore > currentScore ? candidateIndex : currentIndex
            }

            return stableIdentity(values[candidateIndex]) < stableIdentity(values[currentIndex])
                ? candidateIndex
                : currentIndex
        }
    }

    private static func comparableScore(_ score: Double?) -> Double {
        // Existing rows may not have a score; they sort below scored photos.
        guard let score, !score.isNaN else { return -.infinity }
        return score
    }
}

protocol AlbumStore: Sendable {
    func album(for weekKey: String) async throws -> WeeklyAlbumSnapshot?
    func listAlbums() async throws -> [WeeklyAlbumSummary]
    func upsert(_ draft: CurationDraft) async throws -> WeeklyAlbumSnapshot
    func savedAlbumCount() async throws -> Int
}

enum AlbumStoreError: Error, Equatable, Sendable {
    case invalidDraft
    case saveFailed
    case unavailable
}

actor UnavailableAlbumStore: AlbumStore {
    func album(for weekKey: String) async throws -> WeeklyAlbumSnapshot? {
        _ = weekKey
        throw AlbumStoreError.unavailable
    }

    func listAlbums() async throws -> [WeeklyAlbumSummary] {
        throw AlbumStoreError.unavailable
    }

    func upsert(_ draft: CurationDraft) async throws -> WeeklyAlbumSnapshot {
        _ = draft
        throw AlbumStoreError.unavailable
    }

    func savedAlbumCount() async throws -> Int {
        throw AlbumStoreError.unavailable
    }
}

@ModelActor
actor SwiftDataAlbumStore: AlbumStore {
    func album(for weekKey: String) async throws -> WeeklyAlbumSnapshot? {
        let descriptor = FetchDescriptor<WeeklyAlbumEntity>(predicate: #Predicate { $0.weekKey == weekKey })
        guard let entity = try modelContext.fetch(descriptor).first else { return nil }
        return snapshot(from: entity)
    }

    func listAlbums() async throws -> [WeeklyAlbumSummary] {
        let descriptor = FetchDescriptor<WeeklyAlbumEntity>(sortBy: [SortDescriptor(\.weekStart, order: .reverse)])
        return try modelContext.fetch(descriptor).map(summary(from:))
    }

    func savedAlbumCount() async throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<WeeklyAlbumEntity>())
    }

    func upsert(_ draft: CurationDraft) async throws -> WeeklyAlbumSnapshot {
        guard let validDraft = try? draft.validated() else { throw AlbumStoreError.invalidDraft }
        let now = Date()
        let descriptor = FetchDescriptor<WeeklyAlbumEntity>(predicate: #Predicate { $0.weekKey == validDraft.week.key })
        let existing = try modelContext.fetch(descriptor).first
        let entity: WeeklyAlbumEntity
        let createdAt: Date
        if let existing {
            entity = existing
            createdAt = existing.createdAt
            entity.photos.forEach(modelContext.delete)
            entity.photos.removeAll()
            entity.updatedAt = now
            entity.kindRaw = validDraft.kind.rawValue
            entity.weekStart = validDraft.week.start
            entity.weekEnd = validDraft.week.end
            entity.analysisCutoff = validDraft.analysisCutoff
        } else {
            createdAt = now
            entity = WeeklyAlbumEntity(
                id: UUID(),
                weekKey: validDraft.week.key,
                kind: validDraft.kind,
                weekStart: validDraft.week.start,
                weekEnd: validDraft.week.end,
                analysisCutoff: validDraft.analysisCutoff,
                createdAt: createdAt,
                updatedAt: now,
                coverPhotoID: nil
            )
            modelContext.insert(entity)
        }

        let normalized = validDraft.selected.sorted(by: AlbumStoreOrdering.chronological)
        var photoEntities: [AlbumPhotoEntity] = []
        for (position, photo) in normalized.enumerated() {
            let photoEntity = AlbumPhotoEntity(
                id: UUID(),
                assetLocalIdentifier: photo.id.rawValue,
                capturedAt: photo.capturedAt,
                position: position,
                source: photo.source,
                scoreSnapshot: photo.score
            )
            photoEntity.album = entity
            photoEntities.append(photoEntity)
            modelContext.insert(photoEntity)
        }
        entity.photos = photoEntities
        let coverIndex = AlbumStoreOrdering.bestCoverIndex(
            in: normalized,
            qualityScore: { $0.score },
            stableIdentity: { $0.id.rawValue }
        )
        entity.coverPhotoID = coverIndex.map { photoEntities[$0].id }

        do {
            try modelContext.save()
            guard let saved = try modelContext.fetch(descriptor).first else { throw AlbumStoreError.saveFailed }
            _ = createdAt
            return snapshot(from: saved)
        } catch {
            modelContext.rollback()
            throw AlbumStoreError.saveFailed
        }
    }

    private func snapshot(from entity: WeeklyAlbumEntity) -> WeeklyAlbumSnapshot {
        let photos = entity.photos
            .sorted { $0.position < $1.position }
            .map { photo in
                AlbumPhotoSnapshot(
                    id: photo.id,
                    assetLocalIdentifier: PhotoID(photo.assetLocalIdentifier),
                    capturedAt: photo.capturedAt,
                    position: photo.position,
                    source: photo.source,
                    scoreSnapshot: photo.scoreSnapshot,
                    isAvailable: true
                )
            }
        return WeeklyAlbumSnapshot(
            id: entity.id,
            weekKey: entity.weekKey,
            kind: entity.kind,
            weekStart: entity.weekStart,
            weekEnd: entity.weekEnd,
            analysisCutoff: entity.analysisCutoff,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            coverPhotoID: coverPhotoID(from: entity),
            photos: photos
        )
    }

    private func coverPhotoID(from entity: WeeklyAlbumEntity) -> UUID? {
        // AlbumPhotoEntity.id is a row ID; the source asset ID makes ties stable
        // across stores and upserts while the returned value remains the row ID.
        let index = AlbumStoreOrdering.bestCoverIndex(
            in: entity.photos,
            qualityScore: { $0.scoreSnapshot },
            stableIdentity: { $0.assetLocalIdentifier }
        )
        return index.map { entity.photos[$0].id }
    }

    private func summary(from entity: WeeklyAlbumEntity) -> WeeklyAlbumSummary {
        WeeklyAlbumSummary(
            id: entity.id,
            weekKey: entity.weekKey,
            kind: entity.kind,
            weekStart: entity.weekStart,
            weekEnd: entity.weekEnd,
            createdAt: entity.createdAt,
            photoCount: entity.photos.count,
            availablePhotoCount: entity.photos.count,
            coverPhotoID: coverPhotoID(from: entity)
        )
    }
}

actor InMemoryAlbumStore: AlbumStore {
    private var albums: [String: WeeklyAlbumSnapshot] = [:]

    init(initialAlbums: [WeeklyAlbumSnapshot] = []) {
        self.albums = Dictionary(uniqueKeysWithValues: initialAlbums.map { ($0.weekKey, $0) })
    }

    func album(for weekKey: String) async throws -> WeeklyAlbumSnapshot? {
        albums[weekKey]
    }

    func listAlbums() async throws -> [WeeklyAlbumSummary] {
        albums.values
            .sorted { $0.weekStart > $1.weekStart }
            .map { album in
                WeeklyAlbumSummary(
                    id: album.id,
                    weekKey: album.weekKey,
                    kind: album.kind,
                    weekStart: album.weekStart,
                    weekEnd: album.weekEnd,
                    createdAt: album.createdAt,
                    photoCount: album.photos.count,
                    availablePhotoCount: album.photos.filter(\.isAvailable).count,
                    coverPhotoID: album.coverPhotoID
                )
            }
    }

    func savedAlbumCount() async throws -> Int { albums.count }

    func upsert(_ draft: CurationDraft) async throws -> WeeklyAlbumSnapshot {
        guard let valid = try? draft.validated() else { throw AlbumStoreError.invalidDraft }
        let now = Date()
        let existing = albums[valid.week.key]
        let normalized = valid.selected
            .sorted(by: AlbumStoreOrdering.chronological)
        let photos = normalized
            .enumerated()
            .map { position, photo in
                AlbumPhotoSnapshot(
                    id: UUID(),
                    assetLocalIdentifier: photo.id,
                    capturedAt: photo.capturedAt,
                    position: position,
                    source: photo.source,
                    scoreSnapshot: photo.score,
                    isAvailable: true
                )
            }
        let coverIndex = AlbumStoreOrdering.bestCoverIndex(
            in: normalized,
            qualityScore: { $0.score },
            stableIdentity: { $0.id.rawValue }
        )
        let snapshot = WeeklyAlbumSnapshot(
            id: existing?.id ?? UUID(),
            weekKey: valid.week.key,
            kind: valid.kind,
            weekStart: valid.week.start,
            weekEnd: valid.week.end,
            analysisCutoff: valid.analysisCutoff,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
            coverPhotoID: coverIndex.map { photos[$0].id },
            photos: photos
        )
        albums[valid.week.key] = snapshot
        return snapshot
    }
}

enum WeekkeepSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [WeeklyAlbumEntity.self, AlbumPhotoEntity.self]
    }
}

enum WeekkeepMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [WeekkeepSchemaV1.self]
    }

    static var stages: [MigrationStage] { [] }
}

enum WeekkeepSchema {
    static let schema = Schema(versionedSchema: WeekkeepSchemaV1.self)

    static func liveContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try ModelContainer(
            for: schema,
            migrationPlan: WeekkeepMigrationPlan.self,
            configurations: [configuration]
        )
    }

    static func previewContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: schema,
            migrationPlan: WeekkeepMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
