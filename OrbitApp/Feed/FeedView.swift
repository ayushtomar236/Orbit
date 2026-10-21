import SwiftUI

/// Owner: Dev B. Not implemented in foundation.
struct FeedView: View {
    var body: some View {
        OrbitPlaceholder(
            title: "Campus feed",
            systemImage: "list.bullet.rectangle",
            message: "Dev B: EventRepository.approvedFeed() only. Push EventDetailView(eventId:)."
        )
        .navigationTitle("Feed")
    }
}
