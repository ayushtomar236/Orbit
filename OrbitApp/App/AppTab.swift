import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case feed
    case saved
    case create
    case review
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed: "Feed"
        case .saved: "Saved"
        case .create: "Create"
        case .review: "Review"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .feed: "list.bullet"
        case .saved: "bookmark"
        case .create: "plus.circle"
        case .review: "checkmark.shield"
        case .profile: "person"
        }
    }

    func isVisible(for role: UserRole) -> Bool {
        switch self {
        case .feed, .saved, .profile:
            true
        case .create:
            role == .organizer || role == .admin
        case .review:
            role == .admin
        }
    }
}
