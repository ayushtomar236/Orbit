import SwiftUI

struct MainTabView: View {
    @Environment(AppEnvironment.self) private var environment

    private var role: UserRole {
        environment.profile?.role ?? .student
    }

    var body: some View {
        TabView {
            NavigationStack {
                FeedView()
            }
            .tabItem { Label("Feed", systemImage: "list.bullet") }

            NavigationStack {
                SavedEventsView()
            }
            .tabItem { Label("Saved", systemImage: "bookmark") }

            if role == .organizer || role == .admin {
                NavigationStack {
                    CreateEventView()
                }
                .tabItem { Label("Create", systemImage: "plus.circle") }
            }

            if role == .admin {
                NavigationStack {
                    AdminReviewView()
                }
                .tabItem { Label("Review", systemImage: "checkmark.shield") }
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
