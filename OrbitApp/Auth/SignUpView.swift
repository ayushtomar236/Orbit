import SwiftUI

/// Owner: Dev A.
struct SignUpView: View {
    var body: some View {
        ContentUnavailableView(
            "Sign up",
            systemImage: "pencil",
            description: Text("Dev A: full name, email, password → AuthRepository.signUp.")
        )
        .navigationTitle("Sign up")
    }
}
