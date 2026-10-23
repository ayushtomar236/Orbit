import XCTest
@testable import Orbit

@MainActor
final class EventDetailViewModelTests: XCTestCase {
    func testLoadPopulatesFields() async {
        let fake = FakeEventRepository()
        let id = UUID()
        let item = EventFixture.meta(
            id: id,
            title: "Hack Night",
            venue: "Hall A",
            organizerName: "Riley Organizer",
            posterURL: URL(string: "https://example.com/poster.jpg")
        )
        fake.eventById[id] = item
        let model = EventDetailViewModel(eventId: id, events: fake)

        await model.load()

        XCTAssertEqual(model.item?.event.title, "Hack Night")
        XCTAssertEqual(model.item?.event.venue, "Hall A")
        XCTAssertEqual(model.item?.organizerName, "Riley Organizer")
        XCTAssertEqual(model.item?.event.description, "Details")
        XCTAssertEqual(model.item?.posterURL, URL(string: "https://example.com/poster.jpg"))
        XCTAssertEqual(fake.eventCallCount, 1)
        XCTAssertEqual(fake.approvedFeedCallCount, 0)
        XCTAssertEqual(fake.writeCallCount, 0)
    }

    func testMissingPosterURLIsNil() async {
        let fake = FakeEventRepository()
        let id = UUID()
        fake.eventById[id] = EventFixture.meta(id: id, title: "Hack Night", posterURL: nil)
        let model = EventDetailViewModel(eventId: id, events: fake)

        await model.load()

        XCTAssertNil(model.item?.posterURL)
    }

    func testNotFound() async {
        let fake = FakeEventRepository()
        let model = EventDetailViewModel(eventId: UUID(), events: fake)

        await model.load()

        XCTAssertTrue(model.isNotFound)
        XCTAssertEqual(model.errorMessage, "Event not found.")
        XCTAssertNil(model.item)
    }

    func testNetworkError() async {
        let fake = FakeEventRepository()
        fake.eventError = OrbitError.network("offline")
        let model = EventDetailViewModel(eventId: UUID(), events: fake)

        await model.load()

        XCTAssertEqual(model.errorMessage, "offline")
        XCTAssertFalse(model.isNotFound)
    }

    func testRetryAfterError() async {
        let fake = FakeEventRepository()
        let id = UUID()
        fake.eventError = OrbitError.network("offline")
        let model = EventDetailViewModel(eventId: id, events: fake)
        await model.load()
        fake.eventError = nil
        fake.eventById[id] = EventFixture.meta(id: id, title: "Hack Night")

        await model.load()

        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.item?.event.title, "Hack Night")
        XCTAssertEqual(fake.eventCallCount, 2)
    }

    func testRegisteredOnlyBadge() async {
        let fake = FakeEventRepository()
        let id = UUID()
        fake.eventById[id] = EventFixture.meta(id: id, title: "Hack Night", isRegistered: true, isSaved: false)
        let model = EventDetailViewModel(eventId: id, events: fake)

        await model.load()

        XCTAssertEqual(model.item?.isRegistered, true)
        XCTAssertEqual(model.item?.isSaved, false)
        XCTAssertEqual(fake.writeCallCount, 0)
    }

    func testSavedOnlyBadge() async {
        let fake = FakeEventRepository()
        let id = UUID()
        fake.eventById[id] = EventFixture.meta(id: id, title: "Hack Night", isRegistered: false, isSaved: true)
        let model = EventDetailViewModel(eventId: id, events: fake)

        await model.load()

        XCTAssertEqual(model.item?.isRegistered, false)
        XCTAssertEqual(model.item?.isSaved, true)
        XCTAssertEqual(fake.writeCallCount, 0)
    }

    func testNeitherRegisteredNorSaved() async {
        let fake = FakeEventRepository()
        let id = UUID()
        fake.eventById[id] = EventFixture.meta(id: id, title: "Hack Night")
        let model = EventDetailViewModel(eventId: id, events: fake)

        await model.load()

        XCTAssertEqual(model.item?.isRegistered, false)
        XCTAssertEqual(model.item?.isSaved, false)
        XCTAssertEqual(fake.writeCallCount, 0)
    }
}
