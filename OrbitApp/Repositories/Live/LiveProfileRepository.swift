import Foundation
import Supabase

struct LiveProfileRepository: ProfileRepository {
    let client: SupabaseClient

    func currentProfile() async throws -> Profile {
        let userId = try await client.auth.session.user.id
        if let profile = try await fetchProfile(userId: userId) {
            return profile
        }

        // The auth.users trigger creates profiles atomically on signup. This self-only
        // insert repairs legacy accounts created before the trigger was installed.
        do {
            let _: [Profile] = try await client
                .from("profiles")
                .insert(ProfileInsert(id: userId, fullName: "Student", campus: "Main Campus"))
                .select()
                .execute()
                .value
        } catch {
            // A concurrent restore may have created the row. Re-read before surfacing error.
            if let profile = try await fetchProfile(userId: userId) {
                return profile
            }
            throw error
        }

        guard let profile = try await fetchProfile(userId: userId) else {
            throw OrbitError.unknown("Your account exists, but its profile could not be loaded. Try again.")
        }
        return profile
    }

    private func fetchProfile(userId: UUID) async throws -> Profile? {
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        return profiles.first
    }
}

private struct ProfileInsert: Encodable {
    let id: UUID
    let fullName: String
    let campus: String
}
