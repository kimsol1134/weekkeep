import SwiftUI

struct NotificationPrimerView: View {
    let model: WeeklyFlowModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WeekkeepSpacing.six) {
                HStack {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(WeekkeepColors.success)
                    Spacer()
                }
                Text("notification.title")
                    .font(.weekkeepTitle2)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("SHEET-NOT-01-Title")
                Text("notification.body")
                    .font(.weekkeepBody)
                Text("notification.schedule")
                    .font(.weekkeepHeadline)
                    .foregroundStyle(WeekkeepColors.success)
                    .padding(.vertical, WeekkeepSpacing.two)
                if let nextDate = model.nextEligibleDate {
                    Text(WeekkeepLocalization.string(
                        "notification.nextDate",
                        WeekkeepLocalization.exactDate(
                            nextDate,
                            timeZone: TimeZone(identifier: model.environment.weekCalculator.timeZoneIdentifier) ?? .current
                        )
                    ))
                    .font(.weekkeepCallout)
                    .foregroundStyle(WeekkeepColors.secondaryText)
                    .accessibilityIdentifier("SHEET-NOT-01-NextDate")
                }
                WeekkeepPrimaryButton(title: "notification.primary") {
                    Task { await model.acceptNotificationReminder() }
                }
                WeekkeepSecondaryButton(title: "notification.secondary", action: model.declineNotificationReminder)
            }
            .padding(WeekkeepSpacing.six)
        }
        .weekkeepScreenBackground()
    }
}
