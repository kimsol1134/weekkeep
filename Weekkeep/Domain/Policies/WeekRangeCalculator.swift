import Foundation

struct WeekRangeCalculator: Sendable {
    let timeZoneIdentifier: String

    init(timeZone: TimeZone = .current) {
        self.timeZoneIdentifier = timeZone.identifier
    }

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }

    func startOfWeek(containing date: Date) -> Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        var monday = DateComponents()
        monday.era = components.era
        monday.yearForWeekOfYear = components.yearForWeekOfYear
        monday.weekOfYear = components.weekOfYear
        monday.weekday = 2
        return calendar.date(from: monday) ?? date
    }

    func weekKey(for start: Date) -> String {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: start)
        let year = components.yearForWeekOfYear ?? calendar.component(.year, from: start)
        let week = components.weekOfYear ?? 1
        return String(format: "%04d-W%02d", year, week)
    }

    func welcomeRange(analysisStartedAt: Date) -> WeekRange {
        let start = analysisStartedAt.addingTimeInterval(-7 * 24 * 60 * 60)
        let key = "welcome-" + dayStamp(for: analysisStartedAt)
        return WeekRange(
            key: key,
            start: start,
            end: analysisStartedAt,
            cutoff: analysisStartedAt,
            eligibleFrom: nil,
            eligibleUntil: nil,
            kind: .welcome
        )
    }

    func preferredFirstAlbumRange(now: Date) -> WeekRange {
        let currentMonday = startOfWeek(containing: now)
        let start = calendar.date(byAdding: .day, value: -7, to: currentMonday) ?? now.addingTimeInterval(-7 * 24 * 60 * 60)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 24 * 60 * 60)
        return WeekRange(
            key: "welcome-completed-" + weekKey(for: start),
            start: start,
            end: end,
            cutoff: end,
            eligibleFrom: nil,
            eligibleUntil: nil,
            kind: .welcome
        )
    }

    func rollingFirstAlbumRange(analysisStartedAt: Date) -> WeekRange {
        let start = calendar.date(byAdding: .day, value: -7, to: analysisStartedAt)
            ?? analysisStartedAt
        return WeekRange(
            key: "welcome-rolling-" + dayStamp(for: analysisStartedAt),
            start: start,
            end: analysisStartedAt,
            cutoff: analysisStartedAt,
            eligibleFrom: nil,
            eligibleUntil: nil,
            kind: .welcome
        )
    }

    func firstAlbumRangeCandidates(now: Date) -> (preferred: WeekRange, fallback: WeekRange) {
        (
            preferred: preferredFirstAlbumRange(now: now),
            fallback: rollingFirstAlbumRange(analysisStartedAt: now)
        )
    }

    func selectFirstAlbumRange(
        now: Date,
        preferredEligiblePhotoCount: Int,
        fallbackEligiblePhotoCount: Int
    ) -> FirstAlbumRangeSelection? {
        let candidates = firstAlbumRangeCandidates(now: now)
        if preferredEligiblePhotoCount > 0 {
            return FirstAlbumRangeSelection(
                range: candidates.preferred,
                strategy: .completedCalendarWeek,
                eligiblePhotoCount: preferredEligiblePhotoCount
            )
        }
        guard fallbackEligiblePhotoCount > 0 else { return nil }
        return FirstAlbumRangeSelection(
            range: candidates.fallback,
            strategy: .rollingSevenDayFallback,
            eligiblePhotoCount: fallbackEligiblePhotoCount
        )
    }

    func regularRange(startingAt start: Date) -> WeekRange {
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 24 * 60 * 60)
        let eligibleUntil = calendar.date(byAdding: .day, value: 7, to: end)
        return WeekRange(
            key: weekKey(for: start),
            start: start,
            end: end,
            cutoff: end,
            eligibleFrom: end,
            eligibleUntil: eligibleUntil,
            kind: .regular
        )
    }

    func latestEligibleRegular(now: Date, regularCycleStartsAt: Date?) -> WeekRange? {
        guard let regularCycleStartsAt else { return nil }
        let candidateStart = calendar.date(byAdding: .day, value: -7, to: startOfWeek(containing: now))
        guard let candidateStart, candidateStart >= regularCycleStartsAt else { return nil }
        let candidate = regularRange(startingAt: candidateStart)
        guard let eligibleFrom = candidate.eligibleFrom,
              let eligibleUntil = candidate.eligibleUntil,
              eligibleFrom <= now,
              now < eligibleUntil else {
            return nil
        }
        return candidate
    }

    func latestCompletedRegular(now: Date, regularCycleStartsAt: Date?) -> WeekRange? {
        guard let regularCycleStartsAt else { return nil }
        let candidateStart = calendar.date(byAdding: .day, value: -7, to: startOfWeek(containing: now))
        guard let candidateStart, candidateStart >= regularCycleStartsAt else { return nil }
        let candidate = regularRange(startingAt: candidateStart)
        guard let eligibleFrom = candidate.eligibleFrom, eligibleFrom <= now else { return nil }
        return candidate
    }

    func nextMonday(after date: Date) -> Date {
        let start = startOfWeek(containing: date)
        return calendar.date(byAdding: .day, value: 7, to: start) ?? date
    }

    func regularCycleStart(forWelcomeSavedAt date: Date) -> Date {
        nextMonday(after: date)
    }

    func regularCycleStart(forWelcomeRange range: WeekRange, savedAt date: Date) -> Date {
        guard range.kind == .welcome else { return regularCycleStart(forWelcomeSavedAt: date) }
        switch range.welcomeAlbumRangeStrategy {
        case .completedCalendarWeek:
            return range.end
        case .rollingSevenDayFallback, .legacyRollingWelcome, .none:
            return regularCycleStart(forWelcomeSavedAt: date)
        }
    }

    func regularSequenceBucket(weekStart: Date, regularCycleStartsAt: Date) -> String {
        let start = startOfWeek(containing: regularCycleStartsAt)
        let difference = calendar.dateComponents([.weekOfYear], from: start, to: weekStart).weekOfYear ?? 0
        switch difference + 1 {
        case 1: return "w1"
        case 2: return "w2"
        default: return "w3_plus"
        }
    }

    private func dayStamp(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }
}
