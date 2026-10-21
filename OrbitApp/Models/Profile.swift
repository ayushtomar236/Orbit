import Foundation

struct Profile: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let fullName: String
    let campus: String
    let role: UserRole
    let createdAt: Date
}
