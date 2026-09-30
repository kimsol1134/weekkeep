import Foundation
import UserNotifications

enum WeekkeepNotificationPayload {
    static let deepLinkKey = "deepLink"
    static let weeklyCurrentDeepLink = "weekkeep://weekly/current"
}

enum NotificationDeepLinkParser {
    static func parse(userInfo: [AnyHashable: Any], router: AppRouter = AppRouter()) -> AppDeepLink? {
        guard let rawDeepLink = userInfo[WeekkeepNotificationPayload.deepLinkKey] as? String,
              let url = URL(string: rawDeepLink) else {
            return nil
        }
        return router.parse(url)
    }
}

enum NotificationAuthorization: String, Sendable, Equatable {
    case notDetermined
    case authorized
    case denied
    case provisional
    case ephemeral
}

protocol NotificationClient: Sendable {
    func authorizationStatus() async -> NotificationAuthorization
    func requestAuthorization() async -> NotificationAuthorization
    func scheduleWeeklyReminders(now: Date, regularCycleStartsAt: Date, calendar: Calendar) async throws
    func cancelReminder(for weekKey: String) async
}

struct WeeklyReminderRequest: Equatable, Sendable {
    let targetWeekKey: String
    let reminderDate: Date
}

enum WeeklyReminderSchedule {
    static func requests(
        now: Date,
        regularCycleStartsAt: Date,
        calendar inputCalendar: Calendar,
        calculator: WeekRangeCalculator
    ) -> [WeeklyReminderRequest] {
        var calendar = inputCalendar
        calendar.timeZone = TimeZone(identifier: calculator.timeZoneIdentifier) ?? calendar.timeZone
        let weekStart = calculator.startOfWeek(containing: now)
        var seenWeekKeys = Set<String>()
        return (0..<12).compactMap { offset in
            guard let rawReminderDate = calendar.date(byAdding: .day, value: (offset + 1) * 7, to: weekStart),
                  let targetStart = calendar.date(byAdding: .day, value: -7, to: rawReminderDate),
                  targetStart >= regularCycleStartsAt else { return nil }
            let target = calculator.regularRange(startingAt: targetStart)
            guard seenWeekKeys.insert(target.key).inserted else { return nil }
            var components = calendar.dateComponents([.year, .month, .day], from: rawReminderDate)
            components.hour = 20
            components.minute = 30
            let reminderDate = calendar.date(from: components) ?? rawReminderDate
            return WeeklyReminderRequest(targetWeekKey: target.key, reminderDate: reminderDate)
        }
    }
}

actor LocalNotificationClient: NotificationClient {
    private let center = UNUserNotificationCenter.current()
    private let calculator: WeekRangeCalculator

    init(timeZone: TimeZone = .current) {
        self.calculator = WeekRangeCalculator(timeZone: timeZone)
    }

    func authorizationStatus() async -> NotificationAuthorization {
        let settings = await center.notificationSettings()
        return map(settings.authorizationStatus)
    }

    func requestAuthorization() async -> NotificationAuthorization {
        do {
            _ = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return .denied
        }
        return await authorizationStatus()
    }

    func scheduleWeeklyReminders(now: Date, regularCycleStartsAt: Date, calendar: Calendar) async throws {
        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else { return }
        var calendar = calendar
        calendar.timeZone = TimeZone(identifier: calculator.timeZoneIdentifier) ?? calendar.timeZone
        let requests = WeeklyReminderSchedule.requests(
            now: now,
            regularCycleStartsAt: regularCycleStartsAt,
            calendar: calendar,
            calculator: calculator
        )
        center.removePendingNotificationRequests(
            withIdentifiers: requests.map { "weeklyReminder.\($0.targetWeekKey)" }
        )
        for request in requests {
            var components = calendar.dateComponents([.year, .month, .day], from: request.reminderDate)
            components.hour = 20
            components.minute = 30
            let content = UNMutableNotificationContent()
            content.title = String(localized: "app.name")
            content.body = String(localized: "notification.body")
            content.sound = .default
            content.userInfo = [
                WeekkeepNotificationPayload.deepLinkKey: WeekkeepNotificationPayload.weeklyCurrentDeepLink
            ]
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let notificationRequest = UNNotificationRequest(
                identifier: "weeklyReminder.\(request.targetWeekKey)",
                content: content,
                trigger: trigger
            )
            try await center.add(notificationRequest)
        }
    }

    func cancelReminder(for weekKey: String) async {
        center.removePendingNotificationRequests(withIdentifiers: ["weeklyReminder.\(weekKey)"])
    }

    private func map(_ status: UNAuthorizationStatus) -> NotificationAuthorization {
        switch status {
        case .notDetermined: .notDetermined
        case .authorized: .authorized
        case .denied: .denied
        case .provisional: .provisional
        case .ephemeral: .ephemeral
        @unknown default: .denied
        }
    }
}

#if DEBUG
actor FixtureNotificationClient: NotificationClient {
    private(set) var state: NotificationAuthorization = .notDetermined
    private(set) var scheduledWeekKeys: [String] = []

    func authorizationStatus() async -> NotificationAuthorization { state }

    func requestAuthorization() async -> NotificationAuthorization {
        state = .authorized
        return state
    }

    func scheduleWeeklyReminders(now: Date, regularCycleStartsAt: Date, calendar: Calendar) async throws {
        let calculator = WeekRangeCalculator(timeZone: calendar.timeZone)
        let requests = WeeklyReminderSchedule.requests(
            now: now,
            regularCycleStartsAt: regularCycleStartsAt,
            calendar: calendar,
            calculator: calculator
        )
        for request in requests where !scheduledWeekKeys.contains(request.targetWeekKey) {
            scheduledWeekKeys.append(request.targetWeekKey)
        }
    }

    func cancelReminder(for weekKey: String) async {
        scheduledWeekKeys.removeAll { $0 == weekKey }
    }
}
#endif
