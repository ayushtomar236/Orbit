import SwiftUI

struct MainTabView: View {
    @Environment(AppEnvironment.self) private var environment

    private var role: UserRole {
        environment.profile?.role ?? .student
    }

    var body: some View {
        TabView {
            ForEach(AppTab.allCases.filter { $0.isVisible(for: role) }) { tab in
                NavigationStack {
                    tabRoot(tab)
                }
                .tabItem { Label(tab.title, systemImage: tab.systemImage) }
            }
        }
        .tint(OrbitColors.accent)
    }

    @ViewBuilder
    private func tabRoot(_ tab: AppTab) -> some View {
        switch tab {
        case .feed: FeedView()
        case .saved: SavedEventsView()
        case .create: CreateEventView()
        case .review: AdminReviewView()
        case .profile: ProfileView()
        }
    }
}
