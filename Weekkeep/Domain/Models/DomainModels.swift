import Foundation

enum AlbumKind: String, Codable, CaseIterable, Sendable {
    case welcome
    case regular
}

struct PhotoID: Hashable, Codable, Sendable, CustomStringConvertible {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    var description: String { "PhotoID(<redacted>)" }
}

enum PhotoAuthorization: String, Codable, Sendable, Equatable {
    case notDetermined
    case authorized
    case limited
    case denied
    case restricted

    var accessScope: PhotoAccessScope? {
        switch self {
        case .authorized: .full
        case .limited: .limited
        case .notDetermined, .denied, .restricted: nil
        }
    }
}

enum PhotoAccessScope: String, Codable, Sendable, Equatable {
    case full
    case limited
}

struct PhotoDescriptor: Codable, Equatable, Hashable, Sendable {
    let id: PhotoID
    let capturedAt: Date
    let pixelWidth: Int
    let pixelHeight: Int
    let isFavorite: Bool
    let isHidden: Bool
    let isScreenshot: Bool

    var isEligible: Bool {
        pixelWidth > 0 && pixelHeight > 0 && !isHidden && !isScreenshot
    }
}

enum PhotoSource: String, Codable, Sendable, Equatable {
    case initial
    case replacement
}

struct PhotoReference: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: PhotoID
    let capturedAt: Date
    let pixelWidth: Int
    let pixelHeight: Int
    let score: Double
    var source: PhotoSource

    var identifiableID: PhotoID { id }

    func calendarDayKey(timeZoneIdentifier: String) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .current
        let components = calendar.dateComponents([.year, .month, .day], from: capturedAt)
        return "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
    }

    func isOnSameCalendarDay(as other: PhotoReference, timeZoneIdentifier: String) -> Bool {
        calendarDayKey(timeZoneIdentifier: timeZoneIdentifier) == other.calendarDayKey(timeZoneIdentifier: timeZoneIdentifier)
    }
}

struct WeekRange: Codable, Equatable, Hashable, Sendable, Identifiable {
    let key: String
    let start: Date
    let end: Date
    let cutoff: Date
    let eligibleFrom: Date?
    let eligibleUntil: Date?
    let kind: AlbumKind

    var id: String { key }
}

struct CurationDraft: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let kind: AlbumKind
    let week: WeekRange
    let analysisCutoff: Date
    var selected: [PhotoReference]
    var alternatives: [PhotoReference]
    var replacementCount: Int
    var skippedAssetCount: Int

    var allPhotos: [PhotoReference] { selected + alternatives }

    func replacementCandidates(
        for index: Int,
        timeZoneIdentifier: String,
        includingOtherDays: Bool = false
    ) -> [PhotoReference] {
        guard selected.indices.contains(index) else { return [] }
        let current = selected[index]
        let sameDay = alternatives.filter {
            $0.isOnSameCalendarDay(as: current, timeZoneIdentifier: timeZoneIdentifier)
        }
        guard includingOtherDays else { return sameDay }
        return sameDay + alternatives.filter {
            !$0.isOnSameCalendarDay(as: current, timeZoneIdentifier: timeZoneIdentifier)
        }
    }

    func otherDayReplacementCandidates(
        for index: Int,
        timeZoneIdentifier: String
    ) -> [PhotoReference] {
        guard selected.indices.contains(index) else { return [] }
        let current = selected[index]
        return alternatives.filter {
            !$0.isOnSameCalendarDay(as: current, timeZoneIdentifier: timeZoneIdentifier)
        }
    }

    func replacing(index: Int, with candidate: PhotoReference) throws -> CurationDraft {
        guard selected.indices.contains(index) else { throw DraftError.invalidSelectionIndex }
        guard !selected.contains(where: { $0.id == candidate.id }) else { throw DraftError.duplicatePhoto }
        guard alternatives.contains(where: { $0.id == candidate.id }) else { throw DraftError.candidateUnavailable }

        var copy = self
        let previous = copy.selected[index]
        var replacement = candidate
        replacement.source = .replacement
        copy.selected[index] = replacement
        copy.alternatives = copy.alternatives.filter { $0.id != candidate.id }
        var old = previous
        old.source = .replacement
        copy.alternatives.append(old)
        copy.alternatives.sort {
            if $0.capturedAt != $1.capturedAt { return $0.capturedAt < $1.capturedAt }
            return $0.id.rawValue < $1.id.rawValue
        }
        copy.replacementCount += 1
        return try copy.validated()
    }

    func validated() throws -> CurationDraft {
        guard !selected.isEmpty else { throw DraftError.emptySelection }
        guard selected.count <= 7, alternatives.count <= 7 else { throw DraftError.tooManyPhotos }
        let selectedIDs = Set(selected.map(\.id))
        let alternativeIDs = Set(alternatives.map(\.id))
        guard selectedIDs.count == selected.count else { throw DraftError.duplicatePhoto }
        guard alternativeIDs.count == alternatives.count else { throw DraftError.duplicatePhoto }
        guard selectedIDs.isDisjoint(with: alternativeIDs) else { throw DraftError.overlappingAlternatives }
        guard allPhotos.allSatisfy({ week.start <= $0.capturedAt && $0.capturedAt < week.end }) else {
            throw DraftError.photoOutsideWeek
        }
        return self
    }

    enum DraftError: Error, Equatable, Sendable {
        case emptySelection
        case tooManyPhotos
        case duplicatePhoto
        case overlappingAlternatives
        case invalidSelectionIndex
        case candidateUnavailable
        case photoOutsideWeek
    }
}

struct AlbumPhotoSnapshot: Codable, Equatable, Hashable, Sendable, Identifiable {
    let id: UUID
    let assetLocalIdentifier: PhotoID
    let capturedAt: Date?
    let position: Int
    let source: PhotoSource
    let scoreSnapshot: Double?
    let isAvailable: Bool

    var identifiableID: UUID { id }
}

struct WeeklyAlbumSnapshot: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let weekKey: String
    let kind: AlbumKind
    let weekStart: Date
    let weekEnd: Date
    let analysisCutoff: Date
    let createdAt: Date
    let updatedAt: Date
    let coverPhotoID: UUID?
    let photos: [AlbumPhotoSnapshot]

    var isMissingAllPhotos: Bool { photos.allSatisfy { !$0.isAvailable } }

    func withAvailability(_ availableIDs: Set<PhotoID>) -> WeeklyAlbumSnapshot {
        WeeklyAlbumSnapshot(
            id: id,
            weekKey: weekKey,
            kind: kind,
            weekStart: weekStart,
            weekEnd: weekEnd,
            analysisCutoff: analysisCutoff,
            createdAt: createdAt,
            updatedAt: updatedAt,
            coverPhotoID: coverPhotoID,
            photos: photos.map { photo in
                AlbumPhotoSnapshot(
                    id: photo.id,
                    assetLocalIdentifier: photo.assetLocalIdentifier,
                    capturedAt: photo.capturedAt,
                    position: photo.position,
                    source: photo.source,
                    scoreSnapshot: photo.scoreSnapshot,
                    isAvailable: availableIDs.contains(photo.assetLocalIdentifier)
                )
            }
        )
    }
}

struct WeeklyAlbumSummary: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let weekKey: String
    let kind: AlbumKind
    let weekStart: Date
    let weekEnd: Date
    let createdAt: Date
    let photoCount: Int
    let availablePhotoCount: Int
    let coverPhotoID: UUID?

    var isPartiallyMissing: Bool { availablePhotoCount < photoCount }
}

struct LocalWeekState: Equatable, Sendable {
    let welcomeSaved: Bool
    let target: WeekRange?
    let savedAlbumID: UUID?
    let savedAlbumCount: Int
}

enum CreationAccess: Equatable, Sendable {
    case active
    case inactive
    case unknown
}

enum ResolutionStage: String, Equatable, Sendable {
    case permission
    case localState
    case photos
    case entitlement
}

enum PhotoPermissionIssue: String, Equatable, Sendable {
    case denied
    case restricted
}

enum WeekRootResolutionError: String, Equatable, Sendable {
    case localState
    case photos
    case entitlement
}

enum LoadState<Value: Equatable & Sendable>: Equatable, Sendable {
    case pending
    case loading
    case loaded(Value)
    case failed
}

struct WeekRootSnapshot: Equatable, Sendable {
    let permission: LoadState<PhotoAuthorization>
    let localState: LoadState<LocalWeekState>
    let eligiblePhotoCount: LoadState<Int>?
    let creationAccess: LoadState<CreationAccess>?
}

enum WeekRootState: Equatable, Sendable {
    case loading(ResolutionStage)
    case permissionBlocked(PhotoPermissionIssue)
    case recoverableError(WeekRootResolutionError)
    case welcomePending(PhotoAccessScope)
    case preRegularWaiting
    case saved(UUID)
    case noEligiblePhotos(PhotoAccessScope)
    case entitlementLocked
    case ready(PhotoAccessScope, photoCount: Int)
}

enum ReviewDestination: Equatable, Sendable {
    case viewer(index: Int)
    case replacement(index: Int)
}

struct ReviewPresentationState: Equatable, Sendable {
    var selectedIndex: Int?
    var destination: ReviewDestination?

    static let initial = ReviewPresentationState(selectedIndex: nil, destination: nil)
}

enum ReviewAction: Equatable, Sendable {
    case tapPhoto(index: Int)
    case viewPhoto(index: Int)
    case replacePhoto(index: Int)
    case dismissDestination
}
