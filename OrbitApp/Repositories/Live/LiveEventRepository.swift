import Foundation
import Supabase

struct LiveEventRepository: EventRepository {
    let client: SupabaseClient

    func approvedFeed() async throws -> [EventWithMeta] {
        let events: [Event] = try await client
            .from("events")
            .select()
            .eq("status", value: EventStatus.approved.rawValue)
            .order("starts_at", ascending: true)
            .execute()
            .value
        return try await withMeta(events)
    }

    func event(id: UUID) async throws -> EventWithMeta {
        let events: [Event] = try await client
            .from("events")
            .select()
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        guard let event = events.first else {
            throw OrbitError.unknown("Event not found.")
        }
        let enriched = try await withMeta([event])
        return enriched[0]
    }

    func create(_ draft: EventDraft, posterJPEG: Data?) async throws -> Event {
        let userId = try await client.auth.session.user.id
        let inserted: [Event] = try await client
            .from("events")
            .insert(EventInsert(
                organizerId: userId,
                title: draft.title,
                description: draft.description,
                venue: draft.venue,
                startsAt: draft.startsAt,
                endsAt: draft.endsAt,
                posterPath: nil,
                status: .pending
            ))
            .select()
            .execute()
            .value
        guard var event = inserted.first else {
            throw OrbitError.unknown("Create event returned no row.")
        }
        if let posterJPEG {
            let path = "\(userId.uuidString.lowercased())/\(event.id.uuidString.lowercased()).jpg"
            try await client.storage
                .from("posters")
                .upload(
                    path,
                    data: posterJPEG,
                    options: FileOptions(contentType: "image/jpeg", upsert: true)
                )
            let updated: [Event] = try await client
                .from("events")
                .update(["poster_path": path])
                .eq("id", value: event.id)
                .select()
                .execute()
                .value
            if let next = updated.first {
                event = next
            }
        }
        return event
    }

    func pendingForReview() async throws -> [Event] {
        try await client
            .from("events")
            .select()
            .eq("status", value: EventStatus.pending.rawValue)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    func setStatus(eventId: UUID, status: EventStatus) async throws {
        try await client
            .from("events")
            .update(["status": status.rawValue])
            .eq("id", value: eventId)
            .execute()
    }

    func register(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        try await client
            .from("event_registrations")
            .insert(UserEventLink(eventId: eventId, userId: userId))
            .execute()
    }

    func unregister(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        try await client
            .from("event_registrations")
            .delete()
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId)
            .execute()
    }

    func save(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        try await client
            .from("saved_events")
            .insert(UserEventLink(eventId: eventId, userId: userId))
            .execute()
    }

    func unsave(eventId: UUID) async throws {
        let userId = try await client.auth.session.user.id
        try await client
            .from("saved_events")
            .delete()
            .eq("event_id", value: eventId)
            .eq("user_id", value: userId)
            .execute()
    }

    func myRegistrations() async throws -> [Event] {
        try await eventsForCurrentUser(from: "event_registrations")
    }

    func mySaved() async throws -> [Event] {
        try await eventsForCurrentUser(from: "saved_events")
    }

    private func eventsForCurrentUser(from table: String) async throws -> [Event] {
        let userId = try await client.auth.session.user.id
        let links: [UserEventLink] = try await client
            .from(table)
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        let ids = links.map(\.eventId)
        guard !ids.isEmpty else { return [] }
        return try await client
            .from("events")
            .select()
            .in("id", values: ids)
            .execute()
            .value
    }

    private func withMeta(_ events: [Event]) async throws -> [EventWithMeta] {
        guard !events.isEmpty else { return [] }
        let userId = try? await client.auth.session.user.id
        let organizerIds = Array(Set(events.map(\.organizerId)))
        let profiles: [Profile] = try await client
            .from("profiles")
            .select()
            .in("id", values: organizerIds)
            .execute()
            .value
        let names = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0.fullName) })

        var registered: Set<UUID> = []
        var saved: Set<UUID> = []
        if let userId {
            let eventIds = events.map(\.id)
            let regs: [UserEventLink] = try await client
                .from("event_registrations")
                .select()
                .eq("user_id", value: userId)
                .in("event_id", values: eventIds)
                .execute()
                .value
            registered = Set(regs.map(\.eventId))
            let saves: [UserEventLink] = try await client
                .from("saved_events")
                .select()
                .eq("user_id", value: userId)
                .in("event_id", values: eventIds)
                .execute()
                .value
            saved = Set(saves.map(\.eventId))
        }

        return events.map { event in
            EventWithMeta(
                event: event,
                organizerName: names[event.organizerId] ?? "Organizer",
                isRegistered: registered.contains(event.id),
                isSaved: saved.contains(event.id),
                posterURL: publicPosterURL(path: event.posterPath)
            )
        }
    }

    private func publicPosterURL(path: String?) -> URL? {
        guard let path, let url = AppConfig.supabaseURL else { return nil }
        return url.appending(path: "storage/v1/object/public/posters/\(path)")
    }
}

private struct EventInsert: Encodable {
    let organizerId: UUID
    let title: String
    let description: String
    let venue: String
    let startsAt: Date
    let endsAt: Date
    let posterPath: String?
    let status: EventStatus
}

private struct UserEventLink: Codable {
    let eventId: UUID
    let userId: UUID
}
