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
    func displayFrames(for id: PhotoID, targetSize: CGSize) async -> AsyncThrowingStream<PhotoDisplayFrame, Error>
    func displayFrames(for id: PhotoID, targetSize: CGSize, priority: PhotoDisplayPriority) async -> AsyncThrowingStream<PhotoDisplayFrame, Error>
    func cachedDisplayFrame(for id: PhotoID) async -> PhotoDisplayFrame?
    func assetAvailability(for ids: [PhotoID]) async -> Set<PhotoID>
}

extension PhotoLibraryClient {
    func cachedDisplayFrame(for id: PhotoID) async -> PhotoDisplayFrame? { nil }

    func displayFrames(
        for id: PhotoID,
        targetSize: CGSize
    ) async -> AsyncThrowingStream<PhotoDisplayFrame, Error> {
        await displayFrames(for: id, targetSize: targetSize, priority: .visible)
    }

    func displayFrames(
        for id: PhotoID,
        targetSize: CGSize,
        priority: PhotoDisplayPriority
    ) async -> AsyncThrowingStream<PhotoDisplayFrame, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    if let cached = await cachedDisplayFrame(for: id) {
                        continuation.yield(cached)
                    }
                    let data = try await displayImage(for: id, targetSize: targetSize)
                    if let image = UIImage(data: data.data) {
                        continuation.yield(PhotoDisplayFrame(image: image))
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
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
    private let imageManager = PHCachingImageManager()
    private let displayGate = PhotoDisplayRequestGate()
    private var displayCache: [PhotoID: PhotoDisplayFrame] = [:]

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
        let image = try await requestUIImage(
            for: id,
            targetSize: targetSize,
            deliveryMode: .fastFormat,
            onPartial: nil,
            fallbackTimeoutNanoseconds: nil
        )
        rememberDisplayFrame(PhotoDisplayFrame(image: image), for: id)
        return try encodedImageData(from: image)
    }

    func displayImage(for id: PhotoID, targetSize: CGSize) async throws -> PhotoImageData {
        let image = try await requestUIImage(
            for: id,
            targetSize: targetSize,
            deliveryMode: .opportunistic,
            onPartial: nil,
            fallbackTimeoutNanoseconds: PhotoKitImageRequestPolicy.shareFallbackTimeoutNanoseconds
        )
        rememberDisplayFrame(PhotoDisplayFrame(image: image), for: id)
        return try encodedImageData(from: image)
    }

    func cachedDisplayFrame(for id: PhotoID) async -> PhotoDisplayFrame? {
        displayCache[id]
    }

    private func rememberDisplayFrame(_ frame: PhotoDisplayFrame, for id: PhotoID) {
        if let existing = displayCache[id], existing.pixelCount >= frame.pixelCount {
            return
        }
        displayCache[id] = frame
        while displayCache.count > 32 {
            guard let smallest = displayCache.min(by: { $0.value.pixelCount < $1.value.pixelCount })?.key else {
                return
            }
            displayCache.removeValue(forKey: smallest)
        }
    }

    func displayFrames(
        for id: PhotoID,
        targetSize: CGSize,
        priority: PhotoDisplayPriority
    ) async -> AsyncThrowingStream<PhotoDisplayFrame, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    if let cached = await self.cachedDisplayFrame(for: id) {
                        continuation.yield(cached)
                        if cached.meets(targetSize) {
                            continuation.finish()
                            return
                        }
                    }

                    try await self.displayGate.withPermit(priority: priority) {
                        if let cached = await self.cachedDisplayFrame(for: id) {
                            continuation.yield(cached)
                            if cached.meets(targetSize) {
                                return
                            }
                        }

                        _ = try await self.requestUIImage(
                            for: id,
                            targetSize: targetSize,
                            deliveryMode: .opportunistic,
                            onPartial: { frame in
                                Task { await self.rememberDisplayFrame(frame, for: id) }
                                continuation.yield(frame)
                            },
                            fallbackTimeoutNanoseconds: nil
                        )
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
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
    private func requestUIImage(
        for id: PhotoID,
        targetSize: CGSize,
        deliveryMode: PHImageRequestOptionsDeliveryMode,
        onPartial: (@Sendable (PhotoDisplayFrame) -> Void)?,
        fallbackTimeoutNanoseconds: UInt64?
    ) async throws -> UIImage {
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.version = .current
        let policyMode: PhotoKitImageRequestPolicy.DeliveryMode =
            deliveryMode == .fastFormat ? .fastFormat : .opportunisticHighQuality

        let requestBox = PhotoImageRequestBox()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<UIImage, Error>) in
                // PhotoKit may invoke its result handler on the main queue even
                // though this client is an actor. Keep the callback independent
                // of actor-isolated state; the request box owns cancellation
                // bookkeeping for the callback's lifetime.
                requestBox.install(
                    continuation,
                    manager: imageManager,
                    fallbackTimeoutNanoseconds: fallbackTimeoutNanoseconds
                )
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
                    switch PhotoKitImageRequestPolicy.decision(
                        hasImage: image != nil,
                        degraded: degraded,
                        deliveryMode: policyMode
                    ) {
                    case .ignore:
                        return
                    case .usePartial:
                        guard let image else { return }
                        onPartial?(PhotoDisplayFrame(image: image))
                        requestBox.storePartial(image)
                    case .complete(let cancelOutstanding):
                        guard let image else {
                            requestBox.resolve(.failure(PhotoAccessChangedError()))
                            return
                        }
                        onPartial?(PhotoDisplayFrame(image: image))
                        requestBox.resolve(.success(image), cancelOutstandingRequest: cancelOutstanding)
                    case .fail:
                        requestBox.resolve(.failure(PhotoAccessChangedError()))
                    }
                }
                requestBox.setRequestID(requestID)
            }
        } onCancel: {
            requestBox.cancel()
        }
    }

    private func encodedImageData(from image: UIImage) throws -> PhotoImageData {
        guard let data = PhotoKitJPEGEncoder.data(from: image) else {
            throw PhotoAccessChangedError()
        }
        return PhotoImageData(
            data: data,
            pixelWidth: Int(image.size.width * image.scale),
            pixelHeight: Int(image.size.height * image.scale)
        )
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
    private var continuation: CheckedContinuation<UIImage, Error>?
    private var requestID: PHImageRequestID?
    private var manager: PHImageManager?
    private var resolved = false
    private var fallback: UIImage?
    private var timeoutTask: Task<Void, Never>?

    func install(
        _ continuation: CheckedContinuation<UIImage, Error>,
        manager: PHImageManager,
        fallbackTimeoutNanoseconds: UInt64?
    ) {
        lock.lock()
        if resolved {
            lock.unlock()
            continuation.resume(throwing: CancellationError())
            return
        }
        self.continuation = continuation
        self.manager = manager
        lock.unlock()

        if let fallbackTimeoutNanoseconds {
            startTimeout(fallbackTimeoutNanoseconds)
        }
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

    func storePartial(_ image: UIImage) {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }
        fallback = image
        lock.unlock()
    }

    func resolve(
        _ result: Result<UIImage, Error>,
        cancelOutstandingRequest: Bool = false
    ) {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }

        let settledResult: Result<UIImage, Error>
        switch result {
        case .success:
            settledResult = result
        case .failure(let error) where error is CancellationError:
            settledResult = result
        case .failure(let error):
            if let fallback {
                settledResult = .success(fallback)
            } else {
                settledResult = .failure(error)
            }
        }

        let shouldCancelOutstanding: Bool
        if case .failure = settledResult {
            shouldCancelOutstanding = true
        } else {
            shouldCancelOutstanding = cancelOutstandingRequest
        }

        resolved = true
        timeoutTask?.cancel()
        let continuation = continuation
        let requestID = requestID
        let managerToCancel = shouldCancelOutstanding ? manager : nil
        self.continuation = nil
        self.requestID = nil
        self.manager = nil
        self.fallback = nil
        self.timeoutTask = nil
        lock.unlock()

        if let managerToCancel, let requestID {
            managerToCancel.cancelImageRequest(requestID)
        }
        continuation?.resume(with: settledResult)
    }

    func cancel() {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }
        resolved = true
        timeoutTask?.cancel()
        let continuation = continuation
        let requestID = requestID
        let requestManager = self.manager
        self.continuation = nil
        self.requestID = nil
        self.manager = nil
        self.fallback = nil
        self.timeoutTask = nil
        lock.unlock()

        if let requestID {
            requestManager?.cancelImageRequest(requestID)
        }
        continuation?.resume(throwing: CancellationError())
    }

    private func startTimeout(_ nanoseconds: UInt64) {
        let task = Task { [weak self] in
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            self?.settleFromTimeout()
        }
        lock.lock()
        if resolved {
            lock.unlock()
            task.cancel()
            return
        }
        timeoutTask = task
        lock.unlock()
    }

    private func settleFromTimeout() {
        lock.lock()
        guard !resolved else {
            lock.unlock()
            return
        }
        resolved = true
        timeoutTask?.cancel()
        let continuation = continuation
        let requestID = requestID
        let manager = manager
        let fallback = fallback
        self.continuation = nil
        self.requestID = nil
        self.manager = nil
        self.fallback = nil
        self.timeoutTask = nil
        lock.unlock()

        if let requestID {
            manager?.cancelImageRequest(requestID)
        }
        if let fallback {
            continuation?.resume(returning: fallback)
        } else {
            continuation?.resume(throwing: PhotoAccessChangedError())
        }
    }
}

