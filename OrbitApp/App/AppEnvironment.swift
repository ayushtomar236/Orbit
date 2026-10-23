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
    var sessionError: String?

    @ObservationIgnored private var authObservationTask: Task<Void, Never>?

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
    func startSessionObservation() {
        guard isConfigured else {
            isSessionReady = true
            return
        }
        guard authObservationTask == nil else { return }

        authObservationTask = Task { [weak self] in
            guard let self else { return }
            for await hasSession in auth.sessionChanges() {
                await applySessionState(hasSession)
            }
        }
    }

    @MainActor
    func signedIn() async throws {
        profile = try await profiles.currentProfile()
        sessionError = nil
        isSignedIn = true
        isSessionReady = true
    }

    @MainActor
    func signedOut() async throws {
        try await auth.signOut()
        profile = nil
        sessionError = nil
        isSignedIn = false
        isSessionReady = true
    }

    @MainActor
    func retryProfileLoad() async {
        do {
            try await signedIn()
        } catch {
            profile = nil
            isSignedIn = false
            sessionError = error.localizedDescription
            isSessionReady = true
        }
    }

    @MainActor
    private func applySessionState(_ hasSession: Bool) async {
        guard hasSession else {
            profile = nil
            sessionError = nil
            isSignedIn = false
            isSessionReady = true
            return
        }

        do {
            try await signedIn()
        } catch {
            profile = nil
            sessionError = error.localizedDescription
            isSignedIn = false
        }
        isSessionReady = true
    }
}
