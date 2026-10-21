import XCTest
@testable import Orbit

final class FakeEventRepositoryTests: XCTestCase {
    func testConfiguredFeedIsReturned() async throws {
        let fake = FakeEventRepository()
        let event = EventFixture.meta(title: "Hack Night")
        fake.feed = [event]

        let loaded = try await fake.approvedFeed()

        XCTAssertEqual(loaded, [event])
        XCTAssertEqual(fake.approvedFeedCallCount, 1)
        XCTAssertEqual(fake.writeCallCount, 0)
    }
}
