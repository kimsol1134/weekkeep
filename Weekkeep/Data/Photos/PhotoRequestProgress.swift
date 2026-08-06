import Foundation

/// The orchestration-level progress contract for PhotoKit requests.
///
/// PhotoLibraryClient intentionally remains a narrow adapter and does not
/// expose PhotoKit request callbacks. One unit is therefore completed only
/// after the pipeline's per-photo `analysisImage` request (including a
/// failure, timeout, or utility-photo skip) has returned to the orchestrator.
/// This is request completion, not byte-level iCloud download progress.
struct PhotoRequestProgress: Equatable, Sendable {
    let completed: Int
    let total: Int

    init(completed: Int, total: Int) {
        let boundedTotal = max(total, 0)
        self.total = boundedTotal
        self.completed = min(max(completed, 0), boundedTotal)
    }

    var fraction: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(completed) / Double(total), 0), 1)
    }
}

struct PhotoRequestProgressAggregator: Sendable {
    private(set) var progress = PhotoRequestProgress(completed: 0, total: 0)

    init(total: Int = 0) {
        reset(total: total)
    }

    mutating func reset(total: Int) {
        progress = PhotoRequestProgress(completed: 0, total: max(total, 0))
    }

    mutating func completeRequest() {
        progress = PhotoRequestProgress(
            completed: min(progress.completed + 1, progress.total),
            total: progress.total
        )
    }

    mutating func completeRemainingRequests() {
        progress = PhotoRequestProgress(completed: progress.total, total: progress.total)
    }

    mutating func cancel() {
        reset(total: 0)
    }
}
