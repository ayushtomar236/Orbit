import SwiftUI

/// Owner: Dev C. Not implemented in foundation.
struct AdminReviewView: View {
    var body: some View {
        OrbitPlaceholder(
            title: "Review",
            systemImage: "checkmark.shield",
            message: "Dev C: pendingForReview() then setStatus approved or rejected."
        )
        .navigationTitle("Review")
    }
}
