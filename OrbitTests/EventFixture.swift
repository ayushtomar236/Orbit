import Foundation
@testable import Orbit

enum EventFixture {
    static func event(
        id: UUID = UUID(),
        title: String,
        description: String = "Details",
        venue: String = "Main Quad",
        startsAt: Date = Date(timeIntervalSince1970: 1_720_000_000),
        endsAt: Date = Date(timeIntervalSince1970: 1_720_003_600),
        posterPath: String? = nil,
        status: EventStatus = .approved
    ) -> Event {
        Event(
            id: id,
            organizerId: UUID(),
            title: title,
            description: description,
            venue: venue,
            startsAt: startsAt,
            endsAt: endsAt,
            posterPath: posterPath,
            status: status,
            createdAt: Date(timeIntervalSince1970: 1_719_000_000),
            updatedAt: Date(timeIntervalSince1970: 1_719_000_000)
        )
    }

    static func meta(
        id: UUID = UUID(),
        title: String,
        venue: String = "Main Quad",
        organizerName: String = "Riley Organizer",
        isRegistered: Bool = false,
        isSaved: Bool = false,
        posterURL: URL? = nil
    ) -> EventWithMeta {
        EventWithMeta(
            event: event(id: id, title: title, venue: venue),
            organizerName: organizerName,
            isRegistered: isRegistered,
            isSaved: isSaved,
            posterURL: posterURL
        )
    }
}
