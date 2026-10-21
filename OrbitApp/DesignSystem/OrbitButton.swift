import SwiftUI

struct OrbitButton: View {
    let title: String
    var enabled: Bool = true
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Text(title)
                .font(OrbitType.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, OrbitSpacing.sm + 4)
        }
        .buttonStyle(.borderedProminent)
        .tint(role == .destructive ? OrbitColors.danger : OrbitColors.accent)
        .disabled(!enabled)
    }
}
