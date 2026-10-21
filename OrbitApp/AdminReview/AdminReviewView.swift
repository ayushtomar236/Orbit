import SwiftUI

/// Owner: Dev C / first-done after Create.
struct AdminReviewView: View {
    var body: some View {
        ContentUnavailableView(
            "Review",
            systemImage: "checkmark.shield",
            description: Text("EventRepository.pendingForReview() then setStatus approved/rejected.")
        )
        .navigationTitle("Review")
    }
}
