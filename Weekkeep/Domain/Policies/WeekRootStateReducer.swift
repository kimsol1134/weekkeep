import Foundation

struct WeekRootStateReducer: Sendable {
    let freeAlbumLimit: Int

    init(freeAlbumLimit: Int = EntitlementPolicy().freeAlbumLimit) {
        self.freeAlbumLimit = max(freeAlbumLimit, 0)
    }

    func reduce(snapshot: WeekRootSnapshot) -> WeekRootState {
        switch snapshot.permission {
        case .pending, .loading:
            return .loading(.permission)
        case .failed:
            return .recoverableError(.photos)
        case let .loaded(permission):
            switch permission {
            case .denied:
                return .permissionBlocked(.denied)
            case .restricted:
                return .permissionBlocked(.restricted)
            case .notDetermined:
                return .loading(.permission)
            case .authorized, .limited:
                break
            }
        }

        switch snapshot.localState {
        case .pending, .loading:
            return .loading(.localState)
        case .failed:
            return .recoverableError(.localState)
        case let .loaded(local):
            guard let accessScope = snapshot.permission.value?.accessScope else {
                return .loading(.permission)
            }
            if !local.welcomeSaved {
                guard let eligiblePhotoCount = snapshot.eligiblePhotoCount else {
                    return .loading(.photos)
                }
                switch eligiblePhotoCount {
                case .pending, .loading:
                    return .loading(.photos)
                case .failed:
                    return .recoverableError(.photos)
                case let .loaded(count):
                    return count == 0 ? .noEligiblePhotos(accessScope) : .welcomePending(accessScope)
                }
            }
            guard local.target != nil else {
                return .preRegularWaiting
            }
            if let savedAlbumID = local.savedAlbumID {
                return .saved(savedAlbumID)
            }

            guard let eligiblePhotoCount = snapshot.eligiblePhotoCount else {
                return .loading(.photos)
            }
            switch eligiblePhotoCount {
            case .pending, .loading:
                return .loading(.photos)
            case .failed:
                return .recoverableError(.photos)
            case let .loaded(count):
                if count == 0 {
                    return .noEligiblePhotos(accessScope)
                }
            }

            // The first two saved records, including Welcome, are a local
            // product allowance. They must not wait on a purchase provider or
            // turn a provider's unknown state into a false lock.
            if local.savedAlbumCount < freeAlbumLimit {
                return .ready(accessScope, photoCount: eligiblePhotoCount.value ?? 0)
            }

            guard let creationAccess = snapshot.creationAccess else {
                return .loading(.entitlement)
            }
            switch creationAccess {
            case .pending, .loading:
                return .loading(.entitlement)
            case .failed:
                return .recoverableError(.entitlement)
            case let .loaded(access):
                switch access {
                case .unknown:
                    return .loading(.entitlement)
                case .active:
                    return .ready(accessScope, photoCount: eligiblePhotoCount.value ?? 0)
                case .inactive:
                    if local.savedAlbumCount >= freeAlbumLimit {
                        return .entitlementLocked
                    }
                    return .ready(accessScope, photoCount: eligiblePhotoCount.value ?? 0)
                }
            }
        }
    }
}

private extension LoadState {
    var value: Value? {
        if case let .loaded(value) = self { return value }
        return nil
    }
}
