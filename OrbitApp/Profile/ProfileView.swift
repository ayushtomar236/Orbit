import SwiftUI

/// Account chrome is foundation. Registration list is Dev C — not implemented here.
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        List {
            Section("Account") {
                Text(environment.profile?.fullName ?? "Unknown")
                Text(environment.profile?.role.title ?? UserRole.student.title)
                Text(environment.profile?.campus ?? "")
            }
            Section {
                Button("Sign out", role: .destructive) {
                    Task { await environment.signedOut() }
                }
            }
            Section("Registered events") {
                Text("Dev C: EventRepository.myRegistrations().")
                    .foregroundStyle(OrbitColors.secondaryText)
            }
        }
        .navigationTitle("Profile")
    }
}
