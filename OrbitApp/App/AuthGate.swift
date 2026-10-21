import SwiftUI

struct AuthGate: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        Group {
            if !environment.isConfigured {
                ContentUnavailableView(
                    "Add Supabase keys",
                    systemImage: "key",
                    description: Text("Copy Secrets.example.xcconfig to Secrets.xcconfig (gitignored) and paste SUPABASE_URL and SUPABASE_ANON_KEY. Tech lead only.")
                )
            } else if !environment.isSessionReady {
                ProgressView("Starting Orbit")
            } else if environment.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .task {
            await environment.restoreSession()
        }
    }
}
