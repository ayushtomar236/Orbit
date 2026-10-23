import SwiftUI

struct AuthGate: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        Group {
            if !environment.isConfigured {
                OrbitPlaceholder(
                    title: "Add Supabase keys",
                    systemImage: "key",
                    message: "Set SUPABASE_URL to the full https:// project URL and SUPABASE_ANON_KEY to the anon or publishable client key in Secrets.xcconfig. Never use a service_role or sb_secret key in the app."
                )
            } else if !environment.isSessionReady {
                ProgressView("Starting Orbit")
            } else if let message = environment.sessionError {
                VStack(spacing: OrbitSpacing.md) {
                    Label("Couldn’t load your profile", systemImage: "exclamationmark.triangle")
                        .font(OrbitType.title)
                    Text(message)
                        .foregroundStyle(OrbitColors.secondaryText)
                        .multilineTextAlignment(.center)
                    Button("Try again") {
                        Task { await environment.retryProfileLoad() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(OrbitColors.accent)
                }
                .padding(OrbitSpacing.xl)
            } else if environment.isSignedIn {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .task {
            environment.startSessionObservation()
        }
    }
}
