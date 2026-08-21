import Foundation

enum PhotoDisplayPriority: Sendable, Equatable, Comparable {
    case hero
    case visible
    case prefetch

    private var rank: Int {
        switch self {
        case .hero: 0
        case .visible: 1
        case .prefetch: 2
        }
    }

    static func < (lhs: PhotoDisplayPriority, rhs: PhotoDisplayPriority) -> Bool {
        lhs.rank < rhs.rank
    }
}

/// Limits concurrent opportunistic iCloud downloads so the hero can sharpen
/// first instead of seven LTE requests competing equally.
actor PhotoDisplayRequestGate {
    static let reviewConcurrencyLimit = 2

    private struct Waiter {
        let id: UUID
        let priority: PhotoDisplayPriority
        let continuation: CheckedContinuation<Bool, Never>
    }

    private let limit: Int
    private var running = 0
    private var waiting: [Waiter] = []

    init(limit: Int = PhotoDisplayRequestGate.reviewConcurrencyLimit) {
        self.limit = max(1, limit)
    }

    func acquire(priority: PhotoDisplayPriority) async -> Bool {
        if Task.isCancelled { return false }
        if running < limit {
            running += 1
            return true
        }

        let id = UUID()
        let granted = await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                waiting.append(Waiter(id: id, priority: priority, continuation: continuation))
                waiting.sort { $0.priority < $1.priority }
            }
        } onCancel: {
            Task { await self.failWaiter(id) }
        }

        if Task.isCancelled {
            if granted {
                release()
            }
            return false
        }
        return granted
    }

    func withPermit<T: Sendable>(
        priority: PhotoDisplayPriority,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        let acquired = await acquire(priority: priority)
        guard acquired else { throw CancellationError() }
        do {
            let result = try await operation()
            release()
            return result
        } catch {
            release()
            throw error
        }
    }

    func release() {
        if waiting.isEmpty {
            running = max(running - 1, 0)
            return
        }
        let next = waiting.removeFirst()
        next.continuation.resume(returning: true)
    }

    private func failWaiter(_ id: UUID) {
        guard let index = waiting.firstIndex(where: { $0.id == id }) else { return }
        let waiter = waiting.remove(at: index)
        waiter.continuation.resume(returning: false)
    }
}
