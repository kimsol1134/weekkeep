import SwiftUI

struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            Group {
                if environment.onboardingCompleted {
                    AppShellView(environment: environment)
                } else {
                    OnboardingView(environment: environment)
                }
            }
            .environment(
                \.weekkeepWindowSafeAreaTop,
                WeekkeepSystemSafeArea.top(
                    for: proxy.size,
                    geometrySafeAreaTop: proxy.safeAreaInsets.top
                )
            )
            .animation(reduceMotion ? nil : .easeInOut(duration: WeekkeepMotion.standard), value: environment.onboardingCompleted)
        }
    }
}

struct AppShellView: View {
    let environment: AppEnvironment

    var body: some View {
        @Bindable var bindableEnvironment = environment
        TabView(selection: $bindableEnvironment.selectedTab) {
            WeeklyTabView(environment: environment)
                .tabItem {
                    WeekkeepTabIcon(kind: .week, isSelected: environment.selectedTab == .week)
                    Text("tab.week")
                        .accessibilityIdentifier("TAB-WEEK")
                }
                .tag(AppTab.week)
            ArchiveTabView(environment: environment)
                .tabItem {
                    WeekkeepTabIcon(kind: .archive, isSelected: environment.selectedTab == .archive)
                    Text("tab.archive")
                        .accessibilityIdentifier("TAB-ARCHIVE")
                }
                .tag(AppTab.archive)
            SettingsTabView(environment: environment)
                .tabItem {
                    WeekkeepTabIcon(kind: .settings, isSelected: environment.selectedTab == .settings)
                    Text("tab.settings")
                        .accessibilityIdentifier("TAB-SETTINGS")
                }
                .tag(AppTab.settings)
        }
        .tint(WeekkeepColors.primaryAction)
        .toolbarBackground(WeekkeepColors.primaryBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(.light)
    }
}

#if DEBUG
#Preview {
    RootView()
        .environment(AppEnvironment.fixtures())
}
#endif
