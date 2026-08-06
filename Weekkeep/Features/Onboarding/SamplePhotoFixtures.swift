import Foundation

enum SamplePhotoFixtures {
    static let assetNames = [
        "OnboardingMoment01",
        "OnboardingMoment02",
        "OnboardingMoment03",
        "OnboardingMoment04",
        "OnboardingMoment05",
        "OnboardingMoment06",
        "OnboardingMoment07"
    ]

    static let photos: [PhotoReference] = (0..<7).map { index in
        PhotoReference(
            id: PhotoID("sample-photo-\(index)"),
            capturedAt: Date(timeIntervalSince1970: 1_750_000_000 + Double(index * 3_600)),
            pixelWidth: 1_200,
            pixelHeight: 1_600,
            score: 0.8 - Double(index) / 100,
            source: .initial
        )
    }

    static func assetName(for index: Int) -> String {
        assetNames[min(max(index, 0), assetNames.count - 1)]
    }
}
