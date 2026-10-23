import XCTest
@testable import Orbit

@MainActor
final class FeedViewModelTests: XCTestCase {
    func testLoadKeepsApprovedOrder() async {
        let fake = FakeEventRepository()
        let first = EventFixture.meta(title: "Hack Night")
        let second = EventFixture.meta(title: "Career Fair")
        fake.feed = [first, second]
        let model = FeedViewModel(events: fake)

        await model.load()

        XCTAssertEqual(model.visibleEvents.map(\.event.title), ["Hack Night", "Career Fair"])
        XCTAssertEqual(fake.approvedFeedCallCount, 1)
        XCTAssertEqual(fake.writeCallCount, 0)
    }

    func testEmptyCampusWhenFeedIsEmpty() async {
        let fake = FakeEventRepository()
        let model = FeedViewModel(events: fake)

        await model.load()

        XCTAssertTrue(model.showsEmptyCampus)
        XCTAssertFalse(model.showsEmptySearch)
    }

    func testLoadErrorSurfacesMessage() async {
        let fake = FakeEventRepository()
        fake.feedError = OrbitError.network("offline")
        let model = FeedViewModel(events: fake)

        await model.load()

        XCTAssertEqual(model.errorMessage, "offline")
        XCTAssertTrue(model.visibleEvents.isEmpty)
    }

    func testRetryAfterErrorLoadsEvents() async {
        let fake = FakeEventRepository()
        fake.feedError = OrbitError.network("offline")
        let model = FeedViewModel(events: fake)
        await model.load()
        fake.feedError = nil
        fake.feed = [EventFixture.meta(title: "Hack Night")]

        await model.load()

        XCTAssertNil(model.errorMessage)
        XCTAssertEqual(model.visibleEvents.count, 1)
        XCTAssertEqual(fake.approvedFeedCallCount, 2)
    }

    func testRefreshReplacesList() async {
        let fake = FakeEventRepository()
        fake.feed = [EventFixture.meta(title: "Hack Night")]
        let model = FeedViewModel(events: fake)
        await model.load()
        fake.feed = [
            EventFixture.meta(title: "Hack Night"),
            EventFixture.meta(title: "Career Fair"),
            EventFixture.meta(title: "Open Mic"),
            EventFixture.meta(title: "Job Talk")
        ]

        await model.load()

        XCTAssertEqual(model.visibleEvents.count, 4)
    }

    func testSearchMatchesTitleVenueAndOrganizerWithoutRefetch() async {
        let fake = FakeEventRepository()
        let hack = EventFixture.meta(title: "Hack Night", venue: "Lab")
        let fair = EventFixture.meta(title: "Career Fair", venue: "Hall A")
        let talk = EventFixture.meta(title: "Fireside", organizerName: "Riley Organizer")
        fake.feed = [hack, fair, talk]
        let model = FeedViewModel(events: fake)
        await model.load()

        model.query = "hack"
        XCTAssertEqual(model.visibleEvents.map(\.id), [hack.id])

        model.query = "HALL"
        XCTAssertEqual(model.visibleEvents.map(\.id), [fair.id])

        model.query = "riley"
        XCTAssertEqual(model.visibleEvents.map(\.id), [talk.id])
        XCTAssertEqual(fake.approvedFeedCallCount, 1)
    }

    func testEmptySearchIsDistinctFromEmptyCampus() async {
        let fake = FakeEventRepository()
        fake.feed = [EventFixture.meta(title: "Hack Night")]
        let model = FeedViewModel(events: fake)
        await model.load()

        model.query = "zzzz"

        XCTAssertTrue(model.showsEmptySearch)
        XCTAssertFalse(model.showsEmptyCampus)
    }

    func testClearingAndWhitespaceQueryRestoresFullList() async {
        let fake = FakeEventRepository()
        fake.feed = [
            EventFixture.meta(title: "Hack Night"),
            EventFixture.meta(title: "Career Fair")
        ]
        let model = FeedViewModel(events: fake)
        await model.load()
        model.query = "hack"
        XCTAssertEqual(model.visibleEvents.count, 1)

        model.query = "  fair  "
        XCTAssertEqual(model.visibleEvents.map(\.event.title), ["Career Fair"])

        model.query = "   "
        XCTAssertEqual(model.visibleEvents.count, 2)
        XCTAssertEqual(fake.approvedFeedCallCount, 1)
    }

    func testDetailEventIdMatchesVisibleRow() async {
        let fake = FakeEventRepository()
        let event = EventFixture.meta(title: "Hack Night")
        fake.feed = [event]
        let model = FeedViewModel(events: fake)
        await model.load()

        XCTAssertEqual(model.detailEventId(at: 0), event.id)
    }
}
