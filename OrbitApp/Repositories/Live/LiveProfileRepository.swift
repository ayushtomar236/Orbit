import Foundation
import Supabase

struct LiveProfileRepository: ProfileRepository {
    let client: SupabaseClient

    func currentProfile() async throws -> Profile {
        let userId = try await client.auth.session.user.id
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        guard let profile = profiles.first else {
            throw OrbitError.unknown("Profile row missing. Check the auth.users trigger.")
        }
        return profile
    }
}
