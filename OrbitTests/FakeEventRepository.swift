import Foundation
import XCTest
@testable import Orbit

final class FakeEventRepository: EventRepository, @unchecked Sendable {
    var feed: [EventWithMeta] = []
    var feedError: Error?
    var pauseFeed = false
    private var feedContinuation: CheckedContinuation<[EventWithMeta], Error>?

    var eventById: [UUID: EventWithMeta] = [:]
    var eventError: Error?
    var pauseEvent = false
    private var eventContinuation: CheckedContinuation<EventWithMeta, Error>?

    var approvedFeedCallCount = 0
    var eventCallCount = 0
    var createCallCount = 0
    var pendingForReviewCallCount = 0
    var setStatusCallCount = 0
    var registerCallCount = 0
    var unregisterCallCount = 0
    var saveCallCount = 0
    var unsaveCallCount = 0
    var myRegistrationsCallCount = 0
    var mySavedCallCount = 0

    func approvedFeed() async throws -> [EventWithMeta] {
        approvedFeedCallCount += 1
        if let feedError {
            throw feedError
        }
        if pauseFeed {
            return try await withCheckedThrowingContinuation { continuation in
                feedContinuation = continuation
            }
        }
        return feed
    }

    func resumeFeed() {
        feedContinuation?.resume(returning: feed)
        feedContinuation = nil
        pauseFeed = false
    }

    func event(id: UUID) async throws -> EventWithMeta {
        eventCallCount += 1
        if let eventError {
            throw eventError
        }
        if pauseEvent {
            return try await withCheckedThrowingContinuation { continuation in
                eventContinuation = continuation
            }
        }
        guard let match = eventById[id] else {
            throw OrbitError.unknown("Event not found.")
        }
        return match
    }

    func resumeEvent() {
        if let id = eventById.keys.first, let match = eventById[id] {
            eventContinuation?.resume(returning: match)
        }
        eventContinuation = nil
        pauseEvent = false
    }

    func create(_ draft: EventDraft, posterJPEG: Data?) async throws -> Event {
        createCallCount += 1
        failForbidden("create")
    }

    func pendingForReview() async throws -> [Event] {
        pendingForReviewCallCount += 1
        failForbidden("pendingForReview")
    }

    func setStatus(eventId: UUID, status: EventStatus) async throws {
        setStatusCallCount += 1
        failForbidden("setStatus")
    }

    func register(eventId: UUID) async throws {
        registerCallCount += 1
        failForbidden("register")
    }

    func unregister(eventId: UUID) async throws {
        unregisterCallCount += 1
        failForbidden("unregister")
    }

    func save(eventId: UUID) async throws {
        saveCallCount += 1
        failForbidden("save")
    }

    func unsave(eventId: UUID) async throws {
        unsaveCallCount += 1
        failForbidden("unsave")
    }

    func myRegistrations() async throws -> [Event] {
        myRegistrationsCallCount += 1
        failForbidden("myRegistrations")
    }

    func mySaved() async throws -> [Event] {
        mySavedCallCount += 1
        failForbidden("mySaved")
    }

    var writeCallCount: Int {
        createCallCount
            + pendingForReviewCallCount
            + setStatusCallCount
            + registerCallCount
            + unregisterCallCount
            + saveCallCount
            + unsaveCallCount
            + myRegistrationsCallCount
            + mySavedCallCount
    }

    private func failForbidden(_ name: String) -> Never {
        XCTFail("EventRepository.\(name) must not be called from Dev B feed/detail")
        fatalError("EventRepository.\(name) must not be called from Dev B feed/detail")
    }
}
