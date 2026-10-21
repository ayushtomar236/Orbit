import Foundation

enum UserRole: String, Codable, Sendable {
    case student
    case organizer
    case admin

    var title: String {
        switch self {
        case .student: "Student"
        case .organizer: "Organizer"
        case .admin: "Admin"
        }
    }
}
