import Foundation
import SwiftUI

private final class WeekkeepLocalizationBundleMarker {}

enum WeekkeepLocalization {
    static func string(_ key: String) -> String {
        localizedFormat(for: key)
    }

    static func string(_ key: String, _ argument: String) -> String {
        String.localizedStringWithFormat(localizedFormat(for: key), argument)
    }

    static func string(_ key: String, _ argument: Int) -> String {
        String.localizedStringWithFormat(localizedFormat(for: key), argument)
    }

    static func string(_ key: String, _ first: Int, _ second: Int) -> String {
        String.localizedStringWithFormat(localizedFormat(for: key), first, second)
    }

    static func progress(_ key: String, completed: Int, total: Int) -> String {
        // The catalog uses the first numeric argument as the plural selector.
        // Keep the visible value in completed / total order through positional
        // formatting while passing total first for the grammar decision.
        String.localizedStringWithFormat(localizedFormat(for: key), total, completed)
    }

    static func string(_ key: String, locale: Locale, _ argument: Int) -> String {
        formatted(key, locale: locale, bundle: localizationBundle(for: locale), arguments: [argument])
    }

    static func string(_ key: String, locale: Locale, _ first: Int, _ second: Int) -> String {
        formatted(key, locale: locale, bundle: localizationBundle(for: locale), arguments: [first, second])
    }

    static func progress(_ key: String, completed: Int, total: Int, locale: Locale) -> String {
        formatted(key, locale: locale, bundle: localizationBundle(for: locale), arguments: [total, completed])
    }

    private static func localizedFormat(for key: String, locale: Locale = .current, bundle: Bundle? = nil) -> String {
        String(
            localized: String.LocalizationValue(key),
            table: "Localizable",
            bundle: bundle ?? Bundle(for: WeekkeepLocalizationBundleMarker.self),
            locale: locale
        )
    }

    private static func formatted(_ key: String, locale: Locale, bundle: Bundle? = nil, arguments: [CVarArg]) -> String {
        String(
            format: localizedFormat(for: key, locale: locale, bundle: bundle),
            locale: locale,
            arguments: arguments
        )
    }

    private static func localizationBundle(for locale: Locale) -> Bundle {
        let appBundle = Bundle(for: WeekkeepLocalizationBundleMarker.self)
        guard let languageCode = locale.language.languageCode?.identifier,
              let path = appBundle.path(forResource: languageCode, ofType: "lproj"),
              let localizedBundle = Bundle(path: path) else {
            return appBundle
        }
        return localizedBundle
    }

    static func dateRange(start: Date, end: Date, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = locale
        calendar.timeZone = timeZone
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
        let startText = formatter.string(from: start)
        let endDate = calendar.date(byAdding: .day, value: -1, to: end) ?? end
        let endText = formatter.string(from: endDate)
        return "\(startText) – \(endText)"
    }

    static func dayLabel(_ date: Date, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter.string(from: date)
    }

    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
}
