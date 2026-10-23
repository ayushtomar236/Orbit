import SwiftUI

/// Account chrome is foundation. Registration list is Dev C — not implemented here.
struct ProfileView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var signOutError: String?
    @State private var isSigningOut = false

    var body: some View {
        List {
            Section("Account") {
                Text(environment.profile?.fullName ?? "Unknown")
                Text(environment.profile?.role.title ?? UserRole.student.title)
                Text(environment.profile?.campus ?? "")
            }
            Section {
                Button(role: .destructive) {
                    Task { await signOut() }
                } label: {
                    if isSigningOut {
                        ProgressView("Signing out")
                    } else {
                        Text("Sign out")
                    }
                }
                .disabled(isSigningOut)
            }
            Section("Registered events") {
                Text("Dev C: EventRepository.myRegistrations().")
                    .foregroundStyle(OrbitColors.secondaryText)
            }
        }
        .navigationTitle("Profile")
        .alert("Couldn’t sign out", isPresented: Binding(
            get: { signOutError != nil },
            set: { if !$0 { signOutError = nil } }
        )) {
            Button("OK", role: .cancel) { signOutError = nil }
        } message: {
            Text(signOutError ?? "Please try again.")
        }
    }

    @MainActor
    private func signOut() async {
        isSigningOut = true
        defer { isSigningOut = false }
        do {
            try await environment.signedOut()
        } catch {
            signOutError = error.localizedDescription
        }
    }
}
