import Foundation
import SwiftData
import XCTest
@testable import Weekkeep

final class AlbumStorePersistenceContractTests: XCTestCase {
    func testInMemoryStoreKeepsChronologicalOrderAndUsesLaterHigherScoringCover() async throws {
        let store = InMemoryAlbumStore()
        let draft = try makeDraft(
            weekKey: "cover-high-score-memory",
            photos: [
                photo(id: "later-high", offset: 1_200, score: 0.99),
                photo(id: "early-low", offset: 0, score: 0.20),
                photo(id: "middle", offset: 600, score: 0.70)
            ]
        )

        let saved = try await store.upsert(draft)
        let loadedValue = try await store.album(for: draft.week.key)
        let loaded = try XCTUnwrap(loadedValue)
        let summaries = try await store.listAlbums()
        let summary = try XCTUnwrap(summaries.first)

        assertCoverContract(
            snapshot: saved,
            loaded: loaded,
            summary: summary,
            expectedOrder: ["early-low", "middle", "later-high"],
            expectedCoverReference: "later-high"
        )
    }

    func testSwiftDataStoreKeepsChronologicalOrderAndUsesLaterHigherScoringCover() async throws {
        let container = try WeekkeepSchema.previewContainer()
        let store = SwiftDataAlbumStore(modelContainer: container)
        let draft = try makeDraft(
            weekKey: "cover-high-score-swiftdata",
            photos: [
                photo(id: "later-high", offset: 1_200, score: 0.99),
                photo(id: "early-low", offset: 0, score: 0.20),
                photo(id: "middle", offset: 600, score: 0.70)
            ]
        )

        let saved = try await store.upsert(draft)
        let loadedValue = try await store.album(for: draft.week.key)
        let loaded = try XCTUnwrap(loadedValue)
        let summaries = try await store.listAlbums()
        let summary = try XCTUnwrap(summaries.first)

        assertCoverContract(
            snapshot: saved,
            loaded: loaded,
            summary: summary,
            expectedOrder: ["early-low", "middle", "later-high"],
            expectedCoverReference: "later-high"
        )
    }

    func testInMemoryStoreBreaksCoverScoreTiesByStablePhotoReferenceIdentity() async throws {
        let store = InMemoryAlbumStore()
        let draft = try makeDraft(
            weekKey: "cover-tie-memory",
            photos: [
                photo(id: "z-early", offset: 0, score: 0.80),
                photo(id: "a-later", offset: 1_200, score: 0.80),
                photo(id: "m-middle", offset: 600, score: 0.40)
            ]
        )

        let saved = try await store.upsert(draft)
        let loadedValue = try await store.album(for: draft.week.key)
        let loaded = try XCTUnwrap(loadedValue)
        let summaries = try await store.listAlbums()
        let summary = try XCTUnwrap(summaries.first)

        assertCoverContract(
            snapshot: saved,
            loaded: loaded,
            summary: summary,
            expectedOrder: ["z-early", "m-middle", "a-later"],
            expectedCoverReference: "a-later"
        )
    }

    func testSwiftDataStoreBreaksCoverScoreTiesByStablePhotoReferenceIdentity() async throws {
        let container = try WeekkeepSchema.previewContainer()
        let store = SwiftDataAlbumStore(modelContainer: container)
        let draft = try makeDraft(
            weekKey: "cover-tie-swiftdata",
            photos: [
                photo(id: "z-early", offset: 0, score: 0.80),
                photo(id: "a-later", offset: 1_200, score: 0.80),
                photo(id: "m-middle", offset: 600, score: 0.40)
            ]
        )

        let saved = try await store.upsert(draft)
        let loadedValue = try await store.album(for: draft.week.key)
        let loaded = try XCTUnwrap(loadedValue)
        let summaries = try await store.listAlbums()
        let summary = try XCTUnwrap(summaries.first)

        assertCoverContract(
            snapshot: saved,
            loaded: loaded,
            summary: summary,
            expectedOrder: ["z-early", "m-middle", "a-later"],
            expectedCoverReference: "a-later"
        )
    }

    func testUpsertKeepsExistingCreatedAtWhileRefreshingCover() async throws {
        let store = InMemoryAlbumStore()
        let firstDraft = try makeDraft(
            weekKey: "cover-created-at",
            photos: [
                photo(id: "first", offset: 0, score: 0.90),
                photo(id: "second", offset: 600, score: 0.20)
            ]
        )
        let secondDraft = try makeDraft(
            weekKey: firstDraft.week.key,
            photos: [
                photo(id: "first", offset: 0, score: 0.10),
                photo(id: "second", offset: 600, score: 0.95)
            ]
        )

        let first = try await store.upsert(firstDraft)
        let second = try await store.upsert(secondDraft)

        XCTAssertEqual(second.id, first.id)
        XCTAssertEqual(second.createdAt, first.createdAt)
        XCTAssertGreaterThanOrEqual(second.updatedAt, first.updatedAt)
        XCTAssertEqual(reference(for: second), "second")
    }

    func testSwiftDataUpsertKeepsExistingCreatedAtWhileRefreshingCover() async throws {
        let container = try WeekkeepSchema.previewContainer()
        let store = SwiftDataAlbumStore(modelContainer: container)
        let firstDraft = try makeDraft(
            weekKey: "cover-created-at-swiftdata",
            photos: [
                photo(id: "first", offset: 0, score: 0.90),
                photo(id: "second", offset: 600, score: 0.20)
            ]
        )
        let secondDraft = try makeDraft(
            weekKey: firstDraft.week.key,
            photos: [
                photo(id: "first", offset: 0, score: 0.10),
                photo(id: "second", offset: 600, score: 0.95)
            ]
        )

        let first = try await store.upsert(firstDraft)
        let second = try await store.upsert(secondDraft)

        XCTAssertEqual(second.id, first.id)
        XCTAssertEqual(second.createdAt, first.createdAt)
        XCTAssertGreaterThanOrEqual(second.updatedAt, first.updatedAt)
        XCTAssertEqual(reference(for: second), "second")
    }

    func testV1SchemaAndMigrationPlanRoundTripAlbumPhotoRelationship() throws {
        XCTAssertEqual(WeekkeepSchemaV1.versionIdentifier, Schema.Version(1, 0, 0))
        XCTAssertEqual(WeekkeepMigrationPlan.schemas.count, 1)
        XCTAssertEqual(WeekkeepMigrationPlan.schemas[0].versionIdentifier, WeekkeepSchemaV1.versionIdentifier)
        XCTAssertTrue(WeekkeepMigrationPlan.stages.isEmpty)
        XCTAssertEqual(WeekkeepSchema.schema.version, WeekkeepSchemaV1.versionIdentifier)

        let fixtureDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("WeekkeepPersistenceV1-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: fixtureDirectory, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: fixtureDirectory) }

        let storeURL = fixtureDirectory.appendingPathComponent("weekkeep.store")
        let albumID = UUID()
        let photoID = UUID()
        let createdAt = Date(timeIntervalSince1970: 1_700_000_000)

        do {
            let container = try makeV1Container(at: storeURL)
            let context = ModelContext(container)
            let album = WeeklyAlbumEntity(
                id: albumID,
                weekKey: "migration-fixture",
                kind: .welcome,
                weekStart: createdAt,
                weekEnd: createdAt.addingTimeInterval(604_800),
                analysisCutoff: createdAt.addingTimeInterval(604_800),
                createdAt: createdAt,
                updatedAt: createdAt,
                coverPhotoID: photoID
            )
            let photo = AlbumPhotoEntity(
                id: photoID,
                assetLocalIdentifier: "migration-photo",
                capturedAt: createdAt.addingTimeInterval(600),
                position: 0,
                source: .initial,
                scoreSnapshot: 0.75
            )
            album.photos = [photo]
            photo.album = album
            context.insert(album)
            context.insert(photo)
            try context.save()
        }

        do {
            let reopened = try makeV1Container(at: storeURL)
            let context = ModelContext(reopened)
            let descriptor = FetchDescriptor<WeeklyAlbumEntity>(
                predicate: #Predicate { $0.weekKey == "migration-fixture" }
            )
            let albums = try context.fetch(descriptor)
            let album = try XCTUnwrap(albums.first)
            let photo = try XCTUnwrap(album.photos.first)

            XCTAssertEqual(albums.count, 1)
            XCTAssertEqual(album.id, albumID)
            XCTAssertEqual(album.weekKey, "migration-fixture")
            XCTAssertEqual(album.createdAt, createdAt)
            XCTAssertEqual(album.updatedAt, createdAt)
            XCTAssertEqual(album.coverPhotoID, photoID)
            XCTAssertEqual(photo.id, photoID)
            XCTAssertEqual(photo.assetLocalIdentifier, "migration-photo")
            XCTAssertEqual(photo.position, 0)
            XCTAssertEqual(photo.scoreSnapshot, 0.75)
            XCTAssertEqual(photo.album?.id, albumID)
        }
    }

    private func makeV1Container(at url: URL) throws -> ModelContainer {
        let schema = Schema(versionedSchema: WeekkeepSchemaV1.self)
        let configuration = ModelConfiguration(
            "persistence-v1-fixture",
            schema: schema,
            url: url,
            cloudKitDatabase: .none
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: WeekkeepMigrationPlan.self,
            configurations: [configuration]
        )
    }

    private func assertCoverContract(
        snapshot: WeeklyAlbumSnapshot,
        loaded: WeeklyAlbumSnapshot,
        summary: WeeklyAlbumSummary,
        expectedOrder: [String],
        expectedCoverReference: String
    ) {
        XCTAssertEqual(snapshot.photos.map { $0.assetLocalIdentifier.rawValue }, expectedOrder)
        XCTAssertEqual(loaded.photos.map { $0.assetLocalIdentifier.rawValue }, expectedOrder)
        XCTAssertEqual(snapshot.coverPhotoID, loaded.coverPhotoID)
        XCTAssertEqual(summary.coverPhotoID, loaded.coverPhotoID)
        XCTAssertEqual(reference(for: loaded), expectedCoverReference)
    }

    private func reference(for snapshot: WeeklyAlbumSnapshot) -> String? {
        guard let coverPhotoID = snapshot.coverPhotoID else { return nil }
        return snapshot.photos.first(where: { $0.id == coverPhotoID })?.assetLocalIdentifier.rawValue
    }

    private func makeDraft(weekKey: String, photos: [PhotoReference]) throws -> CurationDraft {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let week = WeekRange(
            key: weekKey,
            start: start,
            end: start.addingTimeInterval(604_800),
            cutoff: start.addingTimeInterval(604_800),
            eligibleFrom: nil,
            eligibleUntil: nil,
            kind: .welcome
        )
        return try CurationDraft(
            id: UUID(),
            kind: .welcome,
            week: week,
            analysisCutoff: week.cutoff,
            selected: photos,
            alternatives: [],
            replacementCount: 0,
            skippedAssetCount: 0
        ).validated()
    }

    private func photo(id: String, offset: TimeInterval, score: Double) -> PhotoReference {
        PhotoReference(
            id: PhotoID(id),
            capturedAt: Date(timeIntervalSince1970: 1_700_000_000).addingTimeInterval(offset),
            pixelWidth: 1_200,
            pixelHeight: 1_600,
            score: score,
            source: .initial
        )
    }
}
