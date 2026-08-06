import Foundation
import UIKit
#if canImport(Photos)
import Photos
#endif

protocol PhotoLibraryClient: Sendable {
    func authorizationStatus() async -> PhotoAuthorization
    func requestAuthorization() async -> PhotoAuthorization
    func fetchDescriptors(in range: DateInterval, limit: Int) async throws -> [PhotoDescriptor]
    func analysisImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData
    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData
    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID>
}

struct PhotoImageData: Sendable, Equatable {
    let data: Data
    let pixelWidth: Int
    let pixelHeight: Int
}

struct PhotoAccessChangedError: Error, Sendable {}

struct BoundedPhotoFetchIndexSampler: Sendable, Equatable {
    static func indices(totalCount: Int, limit: Int) -> [Int] {
        guard totalCount > 0, limit > 0 else { return [] }
        let sampleCount = min(totalCount, limit)
        guard sampleCount > 1 else { return [totalCount / 2] }

        return (0..<sampleCount).map { slot in
            Int(
                (Int64(slot) * Int64(totalCount - 1))
                    / Int64(sampleCount - 1)
            )
        }
    }
}

actor PhotoKitClient: PhotoLibraryClient {
    private let imageManager = PHImageManager.default()

    func authorizationStatus() async -> PhotoAuthorization {
        #if canImport(Photos)
        return map(PHPhotoLibrary.authorizationStatus(for: .readWrite))
        #else
        return .denied
        #endif
    }

    func requestAuthorization() async -> PhotoAuthorization {
        #if canImport(Photos)
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        return map(status)
        #else
        return .denied
        #endif
    }

    func fetchDescriptors(in range: DateInterval, limit: Int) async throws -> [PhotoDescriptor] {
        #if canImport(Photos)
        let authorization = await authorizationStatus()
        guard authorization == .authorized || authorization == .limited else {
            throw PhotoAccessChangedError()
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate(
            format: "mediaType == %d AND creationDate >= %@ AND creationDate < %@",
            PHAssetMediaType.image.rawValue,
            range.start as NSDate,
            range.end as NSDate
        )

        let assets = PHAsset.fetchAssets(with: options)
        var descriptors: [PhotoDescriptor] = []
        descriptors.reserveCapacity(min(assets.count, limit))
        for index in BoundedPhotoFetchIndexSampler.indices(totalCount: assets.count, limit: limit) {
            let asset = assets.object(at: index)
            let subtype = asset.mediaSubtypes
            let isScreenshot = subtype.contains(.photoScreenshot)
            descriptors.append(PhotoDescriptor(
                id: PhotoID(asset.localIdentifier),
                capturedAt: asset.creationDate ?? range.start,
                pixelWidth: asset.pixelWidth,
                pixelHeight: asset.pixelHeight,
                isFavorite: asset.isFavorite,
                isHidden: asset.isHidden,
                isScreenshot: isScreenshot
            ))
        }
        return descriptors
        #else
        return []
        #endif
    }

    func analysisImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        // Ranking only needs a small, quickly delivered representation. The
        // display path below remains independent and can request a larger
        // opportunistic image for review/export.
        try await requestImage(for: id, targetSize: targetSize, deliveryMode: .fastFormat)
    }

    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        try await requestImage(for: id, targetSize: targetSize, deliveryMode: .opportunistic)
    }

    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID> {
        #if canImport(Photos)
        let localIdentifiers = ids.map(\.rawValue)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: localIdentifiers, options: nil)
        var available = Set<PhotoID>()
        assets.enumerateObjects { asset, _, _ in
            available.insert(PhotoID(asset.localIdentifier))
        }
        return available
        #else
        return []
        #endif
    }

    #if canImport(Photos)
    private func requestImage(
        for id: PhotoID,
        targetSize: CGSize,
        deliveryMode: PHImageRequestOptionsDeliveryMode
    ) async throws -> PhotoImageData {
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.version = .current

        let requestBox = PhotoImageRequestBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PhotoImageData, Error>) in
                // PhotoKit may invoke its result handler on the main queue even
                // though this client is an actor. Keep the callback independent
                // of actor-isolated state; the request box owns cancellation
                // bookkeeping for the callback's lifetime.
                requestBox.install(continuation, manager: imageManager)
                let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id.rawValue], options: nil)
                guard let asset = assets.firstObject else {
                    requestBox.resolve(.failure(PhotoAccessChangedError()))
                    return
                }
                let requestID = imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFit,
                    options: options
                ) { image, info in
                    if let cancelled = info?[PHImageCancelledKey] as? Bool, cancelled {
                        requestBox.resolve(.failure(CancellationError()))
                        return
                    }
                    if let error = info?[PHImageErrorKey] as? Error {
                        requestBox.resolve(.failure(error))
                        return
                    }
                    let degraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                    // Ranking accepts the first fast representation. Display
                    // and share requests still wait for the non-degraded
                    // representation so user-facing image quality is not
                    // changed by the analysis optimization.
                    guard !degraded || deliveryMode == .fastFormat else { return }
                    guard let image, let data = image.jpegData(compressionQuality: 0.85) else {
                        requestBox.resolve(.failure(PhotoAccessChangedError()))
                        return
                    }
                    requestBox.resolve(.success(PhotoImageData(
                        data: data,
                        pixelWidth: Int(image.size.width * image.scale),
                        pixelHeight: Int(image.size.height * image.scale)
                    )), cancelOutstandingRequest: deliveryMode == .fastFormat)
                }
                requestBox.setRequestID(requestID)
            }
        } onCancel: {
            requestBox.cancel(manager: PHImageManager.default())
        }
    }

    private func map(_ status: PHAuthorizationStatus) -> PhotoAuthorization {
        switch status {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .limited: .limited
        case .denied: .denied
        case .restricted: .restricted
        @unknown default: .restricted
        }
    }
    #endif
}

private final class PhotoImageRequestBox: @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<PhotoImageData, Error>?
    private var requestID: PHImageRequestID?
    private var manager: PHImageManager?
    private var resolved = false

    func install(_ continuation: CheckedContinuation<PhotoImageData, Error>, manager: PHImageManager) {
        lock.lock()
        if resolved {
            lock.unlock()
            continuation.resume(throwing: CancellationError())
            return
        }
        self.continuation = continuation
        self.manager = manager
        lock.unlock()
    }

    func setRequestID(_ requestID: PHImageRequestID) {
        lock.lock()
        if resolved {
            let manager = self.manager
            lock.unlock()
            manager?.cancelImageRequest(requestID)
            return
        }
        self.requestID = requestID
        lock.unlock()
    }

    func resolve(
        _ result: Result<PhotoImageData, Error>,
        cancelOutstandingRequest: Bool = false
    ) {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }
        resolved = true
        let continuation = continuation
        let requestID = requestID
        let manager = cancelOutstandingRequest ? manager : nil
        self.continuation = nil
        self.requestID = nil
        self.manager = nil
        lock.unlock()

        if let manager, let requestID {
            manager.cancelImageRequest(requestID)
        }
        continuation?.resume(with: result)
    }

    func cancel(manager: PHImageManager) {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }
        resolved = true
        let continuation = continuation
        let requestID = requestID
        let requestManager = self.manager
        self.continuation = nil
        self.requestID = nil
        self.manager = nil
        lock.unlock()

        if let requestID {
            (requestManager ?? manager).cancelImageRequest(requestID)
        }
        continuation?.resume(throwing: CancellationError())
    }
}
