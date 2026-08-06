import Foundation

struct ReplacementCandidatePresentation: Equatable, Sendable {
    let showsOtherDaysAction: Bool
    let showsCloseOnly: Bool

    init(sameDayCount: Int, otherDayCount: Int) {
        let hasSameDayCandidates = sameDayCount > 0
        let hasOtherDayCandidates = otherDayCount > 0
        showsCloseOnly = !hasSameDayCandidates && !hasOtherDayCandidates
        showsOtherDaysAction = hasOtherDayCandidates
    }
}

enum WeeklyReviewDateFormatting {
    static func candidateLabel(
        _ date: Date,
        locale: Locale = .current,
        timeZoneIdentifier: String
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier) ?? .gmt
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
