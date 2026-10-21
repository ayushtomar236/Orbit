import Foundation

enum EventStatus: String, Codable, Sendable {
    case pending
    case approved
    case rejected
}
