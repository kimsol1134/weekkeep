import SwiftUI

extension Font {
    static let weekkeepDisplay = Font.custom("LINESeedSansKR-Bold", size: 38, relativeTo: .largeTitle)
    static let weekkeepTitle = Font.custom("LINESeedSansKR-Bold", size: 34, relativeTo: .title)
    static let weekkeepTitle2 = Font.custom("LINESeedSansKR-Bold", size: 28, relativeTo: .title2)
    static let weekkeepHeadline = Font.custom("LINESeedSansKR-Bold", size: 18, relativeTo: .headline)
    static let weekkeepBody = Font.custom("LINESeedSansKR-Regular", size: 17, relativeTo: .body)
    static let weekkeepCallout = Font.custom("LINESeedSansKR-Regular", size: 15, relativeTo: .callout)
    static let weekkeepCaption = Font.custom("LINESeedSansKR-Regular", size: 13, relativeTo: .caption)
    static let weekkeepNavigation = Font.custom("LINESeedSansKR-Regular", size: 16, relativeTo: .body)
}

extension View {
    func weekkeepTextPrimary() -> some View {
        foregroundStyle(WeekkeepColors.primaryText)
    }

    func weekkeepScreenBackground() -> some View {
        background(WeekkeepColors.primaryBackground.ignoresSafeArea())
    }
}
