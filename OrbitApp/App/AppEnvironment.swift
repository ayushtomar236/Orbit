import Foundation
import Observation

@Observable
final class AppEnvironment {
    let auth: AuthRepository
    let profiles: ProfileRepository
    let events: EventRepository
    let isConfigured: Bool

    var profile: Profile?
    var isSessionReady = false
    var isSignedIn = false

    init(
        auth: AuthRepository? = nil,
        profiles: ProfileRepository? = nil,
        events: EventRepository? = nil
    ) {
        isConfigured = AppConfig.isConfigured
        if let client = SupabaseFactory.client {
            self.auth = auth ?? LiveAuthRepository(client: client)
            self.profiles = profiles ?? LiveProfileRepository(client: client)
            self.events = events ?? LiveEventRepository(client: client)
        } else {
            self.auth = auth ?? UnconfiguredAuthRepository()
            self.profiles = profiles ?? UnconfiguredProfileRepository()
            self.events = events ?? UnconfiguredEventRepository()
        }
    }

    @MainActor
    func restoreSession() async {
        guard isConfigured else {
            isSessionReady = true
            return
        }
        do {
            if try await auth.hasSession() {
                profile = try await profiles.currentProfile()
                isSignedIn = true
            } else {
                profile = nil
                isSignedIn = false
            }
        } catch {
            profile = nil
            isSignedIn = false
        }
        isSessionReady = true
    }

    @MainActor
    func signedIn() async throws {
        profile = try await profiles.currentProfile()
        isSignedIn = true
    }

    @MainActor
    func signedOut() async {
        try? await auth.signOut()
        profile = nil
        isSignedIn = false
    }
}
