import SwiftUI

struct AuthGate: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        Group {
            if !environment.isConfigured {
                OrbitPlaceholder(
                    title: "Add Supabase keys",
                    systemImage: "key",
                    message: "Copy Secrets.example.xcconfig to Secrets.xcconfig and set SUPABASE_URL and SUPABASE_ANON_KEY from the dashboard. Values stay local."
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
