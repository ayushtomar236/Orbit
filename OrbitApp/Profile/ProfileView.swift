import SwiftUI

/// Owner: Dev A (profile fields) / Dev C (registration list).
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        List {
            Section("Account") {
                Text(environment.profile?.fullName ?? "Unknown")
                Text(environment.profile?.role.rawValue ?? "student")
                Text(environment.profile?.campus ?? "")
            }
            Section {
                Button("Sign out", role: .destructive) {
                    Task { await environment.signedOut() }
                }
            }
            Section("TODO") {
                Text("Dev C: list EventRepository.myRegistrations().")
            }
        }
        .navigationTitle("Profile")
    }
}
