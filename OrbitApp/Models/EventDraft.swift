import Foundation

struct EventDraft: Sendable {
    var title: String
    var description: String
    var venue: String
    var startsAt: Date
    var endsAt: Date
}
