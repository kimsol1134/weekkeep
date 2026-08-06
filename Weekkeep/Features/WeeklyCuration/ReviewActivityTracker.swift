import Foundation

struct ReviewActivityTracker: Sendable, Equatable {
    private(set) var accumulated: TimeInterval = 0
    private(set) var startedAt: Date?

    mutating func setActive(_ active: Bool, at now: Date) {
        if active {
            guard startedAt == nil else { return }
            startedAt = now
        } else if let startedAt {
            accumulated += max(0, now.timeIntervalSince(startedAt))
            self.startedAt = nil
        }
    }

    func elapsed(at now: Date) -> TimeInterval {
        guard let startedAt else { return accumulated }
        return accumulated + max(0, now.timeIntervalSince(startedAt))
    }

    mutating func reset() {
        accumulated = 0
        startedAt = nil
    }
}
