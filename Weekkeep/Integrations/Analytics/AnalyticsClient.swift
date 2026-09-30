import Foundation
#if canImport(PostHog)
import PostHog
#endif

enum ShareArtifactFormatAnalyticsValue: String, CaseIterable, Sendable, Equatable {
    case story
    case post
}

enum ShareEntryPointAnalyticsValue: String, CaseIterable, Sendable, Equatable {
    case saveConfirmation = "save_confirmation"
    case archiveDetail = "archive_detail"
}

enum WeeklyEntryPointAnalyticsValue: String, CaseIterable, Sendable, Equatable {
    case direct
    case notification
}

enum AnalyticsEvent: Sendable, Equatable {
    case onboardingStarted(locale: String, appVersion: String)
    case photoPermissionResolved(status: String)
    case curationStarted(albumKind: AlbumKind, candidateCountBucket: String)
    case curationCompleted(durationBucket: String, selectedCount: Int)
    case curationFailed(errorKind: String)
    case photoReplaced(replacementIndex: Int)
    case albumSaved(albumKind: AlbumKind, regularSequenceBucket: String, selectedCount: Int, replacementCount: Int, activeReviewDurationBucket: String)
    case shareSheetOpened(format: ShareArtifactFormatAnalyticsValue, entryPoint: ShareEntryPointAnalyticsValue)
    case shareCompleted(format: ShareArtifactFormatAnalyticsValue, entryPoint: ShareEntryPointAnalyticsValue)
    case eligibleWeekOpened(entryPoint: WeeklyEntryPointAnalyticsValue)
    case notificationPermissionResolved(status: String)
    case paywallViewed(freeAlbumCount: Int)
    case purchaseResolved(result: String, productType: String, localizedPriceBucket: String?)
    case restoreResolved(result: String)

    var name: String {
        switch self {
        case .onboardingStarted: "onboarding_started"
        case .photoPermissionResolved: "photo_permission_resolved"
        case .curationStarted: "curation_started"
        case .curationCompleted: "curation_completed"
        case .curationFailed: "curation_failed"
        case .photoReplaced: "photo_replaced"
        case .albumSaved: "album_saved"
        case .shareSheetOpened: "share_sheet_opened"
        case .shareCompleted: "share_completed"
        case .eligibleWeekOpened: "eligible_week_opened"
        case .notificationPermissionResolved: "notification_permission_resolved"
        case .paywallViewed: "paywall_viewed"
        case .purchaseResolved: "purchase_resolved"
        case .restoreResolved: "restore_resolved"
        }
    }

    var properties: [String: String] {
        switch self {
        case let .onboardingStarted(locale, appVersion):
            return ["locale": locale, "app_version": appVersion]
        case let .photoPermissionResolved(status):
            return ["status": status]
        case let .curationStarted(albumKind, bucket):
            return ["album_kind": albumKind.rawValue, "candidate_count_bucket": bucket]
        case let .curationCompleted(durationBucket, selectedCount):
            return ["duration_bucket": durationBucket, "selected_count": String(selectedCount)]
        case let .curationFailed(errorKind):
            return ["error_kind": errorKind]
        case let .photoReplaced(replacementIndex):
            return ["replacement_index": String(replacementIndex)]
        case let .albumSaved(albumKind, sequence, selectedCount, replacementCount, duration):
            return [
                "album_kind": albumKind.rawValue,
                "regular_sequence_bucket": sequence,
                "selected_count": String(selectedCount),
                "replacement_count": String(replacementCount),
                "active_review_duration_bucket": duration
            ]
        case let .shareSheetOpened(format, entryPoint):
            return [
                "format": format.rawValue,
                "entry_point": entryPoint.rawValue
            ]
        case let .shareCompleted(format, entryPoint):
            return [
                "format": format.rawValue,
                "entry_point": entryPoint.rawValue
            ]
        case let .eligibleWeekOpened(entryPoint):
            return ["entry_point": entryPoint.rawValue]
        case let .notificationPermissionResolved(status):
            return ["status": status]
        case let .paywallViewed(freeAlbumCount):
            return ["free_album_count": String(freeAlbumCount)]
        case let .purchaseResolved(result, productType, priceBucket):
            var values = ["result": result, "product_type": productType]
            if let priceBucket { values["localized_price_bucket"] = priceBucket }
            return values
        case let .restoreResolved(result):
            return ["result": result]
        }
    }
}

enum CandidateCountBucket: String, CaseIterable, Sendable, Equatable {
    case zero = "0"
    case oneToSix = "1-6"
    case sevenToFourteen = "7-14"
    case fifteenToThirty = "15-30"
    case thirtyOneToFifty = "31-50"
    case fiftyOneToOneHundred = "51-100"
    case overOneHundred = "100+"

    static func forCount(_ count: Int) -> Self {
        switch max(count, 0) {
        case 0: .zero
        case 1...6: .oneToSix
        case 7...14: .sevenToFourteen
        case 15...30: .fifteenToThirty
        case 31...50: .thirtyOneToFifty
        case 51...100: .fiftyOneToOneHundred
        default: .overOneHundred
        }
    }
}

enum CurationDurationBucket: String, CaseIterable, Sendable, Equatable {
    case underThirtySeconds = "under_30s"
    case thirtyToSixtySeconds = "30_60s"
    case sixtyToOneHundredTwentySeconds = "60_120s"
    case overOneHundredTwentySeconds = "over_120s"

    static func forDuration(_ duration: TimeInterval) -> Self {
        guard duration.isFinite else { return .overOneHundredTwentySeconds }
        switch duration {
        case ..<30: return .underThirtySeconds
        case ..<60: return .thirtyToSixtySeconds
        case ..<120: return .sixtyToOneHundredTwentySeconds
        default: return .overOneHundredTwentySeconds
        }
    }
}

enum AnalyticsBucketContract {
    static func candidateCount(for count: Int) -> String {
        CandidateCountBucket.forCount(count).rawValue
    }

    static func duration(for duration: TimeInterval) -> String {
        CurationDurationBucket.forDuration(duration).rawValue
    }

    static let candidateCountValues = Set(CandidateCountBucket.allCases.map(\.rawValue))
    static let durationValues = Set(CurationDurationBucket.allCases.map(\.rawValue))
}

protocol AnalyticsClient: Sendable {
    func capture(_ event: AnalyticsEvent) async
    func flush() async
}

enum AnalyticsSchema {
    static let allowedEventNames: Set<String> = [
        "onboarding_started", "photo_permission_resolved", "curation_started", "curation_completed",
        "curation_failed", "photo_replaced", "album_saved", "notification_permission_resolved",
        "share_sheet_opened", "share_completed", "eligible_week_opened", "paywall_viewed", "purchase_resolved", "restore_resolved"
    ]
    static let forbiddenFragments = [
        "asset", "photo", "localidentifier", "filename", "path", "location", "capture", "weekkey",
        "thumbnail", "pixel", "caption", "exif", "coordinate", "user_text"
    ]

    static let allowedPropertyKeys: [String: Set<String>] = [
        "onboarding_started": ["locale", "app_version"],
        "photo_permission_resolved": ["status"],
        "curation_started": ["album_kind", "candidate_count_bucket"],
        "curation_completed": ["duration_bucket", "selected_count"],
        "curation_failed": ["error_kind"],
        "photo_replaced": ["replacement_index"],
        "album_saved": [
            "album_kind", "regular_sequence_bucket", "selected_count", "replacement_count",
            "active_review_duration_bucket"
        ],
        "share_sheet_opened": ["format", "entry_point"],
        "share_completed": ["format", "entry_point"],
        "eligible_week_opened": ["entry_point"],
        "notification_permission_resolved": ["status"],
        "paywall_viewed": ["free_album_count"],
        "purchase_resolved": ["result", "product_type", "localized_price_bucket"],
        "restore_resolved": ["result"]
    ]

    static func validate(_ event: AnalyticsEvent) -> Bool {
        sanitizedProperties(for: event) != nil
    }

    static func sanitizedProperties(for event: AnalyticsEvent) -> [String: String]? {
        let properties = event.properties.reduce(into: [String: Any]()) { result, item in
            result[item.key] = item.value
        }
        return sanitizedProperties(eventName: event.name, properties: properties)
    }

    static func sanitizedProperties(
        eventName: String,
        properties: [String: Any]
    ) -> [String: String]? {
        guard allowedEventNames.contains(eventName), let allowed = allowedPropertyKeys[eventName] else { return nil }

        var sanitized: [String: String] = [:]
        for (key, value) in properties {
            guard allowed.contains(key) else { continue }
            guard isSafeKey(key), let stringValue = value as? String,
                  isSafeValue(stringValue),
                  isApprovedBucketValue(stringValue, eventName: eventName, propertyKey: key) else {
                return nil
            }
            sanitized[key] = stringValue
        }
        return sanitized
    }

    static func isSafeKey(_ key: String) -> Bool {
        let lowercased = key.lowercased()
        return !forbiddenFragments.contains(where: lowercased.contains)
    }

    static func isSafeValue(_ value: String) -> Bool {
        let lowercased = value.lowercased()
        return !forbiddenFragments.contains(where: lowercased.contains)
    }

    private static func isApprovedBucketValue(
        _ value: String,
        eventName: String,
        propertyKey: String
    ) -> Bool {
        switch (eventName, propertyKey) {
        case ("curation_started", "candidate_count_bucket"):
            return AnalyticsBucketContract.candidateCountValues.contains(value)
        case ("curation_completed", "duration_bucket"),
             ("album_saved", "active_review_duration_bucket"):
            return AnalyticsBucketContract.durationValues.contains(value)
        case ("share_sheet_opened", "format"):
            return ShareArtifactFormatAnalyticsValue.allCases.map(\.rawValue).contains(value)
        case ("share_sheet_opened", "entry_point"):
            return ShareEntryPointAnalyticsValue.allCases.map(\.rawValue).contains(value)
        case ("share_completed", "format"):
            return ShareArtifactFormatAnalyticsValue.allCases.map(\.rawValue).contains(value)
        case ("share_completed", "entry_point"):
            return ShareEntryPointAnalyticsValue.allCases.map(\.rawValue).contains(value)
        case ("eligible_week_opened", "entry_point"):
            return WeeklyEntryPointAnalyticsValue.allCases.map(\.rawValue).contains(value)
        default:
            return true
        }
    }

    #if canImport(PostHog)
    static func sanitize(_ event: PostHogEvent) -> PostHogEvent? {
        guard let sanitized = sanitizedProperties(eventName: event.event, properties: event.properties) else { return nil }
        event.properties = sanitized.reduce(into: [String: Any]()) { result, item in
            result[item.key] = item.value
        }
        return event
    }
    #endif
}

actor NoopAnalyticsClient: AnalyticsClient {
    func capture(_ event: AnalyticsEvent) async {
        _ = AnalyticsSchema.validate(event)
    }

    func flush() async {}
}

#if canImport(PostHog)
actor PostHogAnalyticsClient: AnalyticsClient {
    private let sdk: PostHogSDK

    init(projectToken: String, host: URL) {
        let config = PostHogConfig(projectToken: projectToken, host: host.absoluteString)
        config.personProfiles = .never
        config.setDefaultPersonProperties = false
        config.enableSwizzling = false
        config.captureApplicationLifecycleEvents = false
        config.captureScreenViews = false
        config.captureElementInteractions = false
        config.rageClickConfig.enabled = false
        config.capturePushNotificationSubscriptions = false
        config.capturePushNotificationOpened = false
        config.preloadFeatureFlags = false
        config.sendFeatureFlagEvent = false
        config.sessionReplay = false
        config.surveys = false
        config.tracingHeaders = []
        config.errorTrackingConfig.autoCapture = false
        config.setBeforeSend { event in AnalyticsSchema.sanitize(event) }
        sdk = PostHogSDK.with(config)
    }

    func capture(_ event: AnalyticsEvent) async {
        guard let properties = AnalyticsSchema.sanitizedProperties(for: event) else { return }
        let sdkProperties = properties.reduce(into: [String: Any]()) { result, item in
            result[item.key] = item.value
        }
        sdk.capture(event.name, properties: sdkProperties)
    }

    func flush() async {
        sdk.flush()
    }
}
#else
actor PostHogAnalyticsClient: AnalyticsClient {
    init(projectToken _: String, host _: URL) {}
    func capture(_: AnalyticsEvent) async {}
    func flush() async {}
}
#endif
