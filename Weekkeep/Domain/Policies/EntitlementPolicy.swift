import Foundation

struct EntitlementPolicy: Sendable {
    let freeAlbumLimit: Int

    init(freeAlbumLimit: Int = 2) {
        self.freeAlbumLimit = freeAlbumLimit
    }

    func canCreate(savedAlbumCount: Int, entitlement: CreationAccess) -> Bool {
        switch entitlement {
        case .active:
            true
        case .inactive:
            savedAlbumCount < freeAlbumLimit
        case .unknown:
            false
        }
    }

    func shouldShowPaywall(targetIsSaved: Bool, eligiblePhotoCount: Int, savedAlbumCount: Int, entitlement: CreationAccess) -> Bool {
        !targetIsSaved && eligiblePhotoCount > 0 && savedAlbumCount >= freeAlbumLimit && entitlement == .inactive
    }
}
