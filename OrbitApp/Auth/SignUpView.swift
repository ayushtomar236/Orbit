import SwiftUI

/// Owner: Dev A. Not implemented in foundation.
struct SignUpView: View {
    var body: some View {
        OrbitPlaceholder(
            title: "Sign up",
            systemImage: "pencil",
            message: "Dev A: full name, email, password → AuthRepository.signUp. New users are always student."
        )
        .navigationTitle("Sign up")
    }
}
