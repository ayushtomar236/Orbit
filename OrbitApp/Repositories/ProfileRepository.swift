import Foundation

protocol ProfileRepository: Sendable {
    func currentProfile() async throws -> Profile
}
