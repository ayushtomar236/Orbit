import SwiftUI

struct EventDetailView: View {
    @Environment(AppEnvironment.self) private var environment
    let eventId: UUID
    @State private var model: EventDetailViewModel?

    var body: some View {
        Group {
            if let model {
                detailContent(model)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Event")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if model == nil {
                model = EventDetailViewModel(eventId: eventId, events: environment.events)
            }
            await model?.load()
        }
    }

    @ViewBuilder
    private func detailContent(_ model: EventDetailViewModel) -> some View {
        if model.isLoading && model.item == nil {
            ProgressView("Loading event")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if model.isNotFound {
            OrbitPlaceholder(
                title: "Event not found",
                systemImage: "calendar.badge.exclamationmark",
                message: "This event isn’t available."
            )
        } else if let message = model.errorMessage, model.item == nil {
            ContentUnavailableView {
                Label("Couldn’t load event", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") {
                    Task { await model.load() }
                }
            }
        } else if let item = model.item {
            ScrollView {
                VStack(alignment: .leading, spacing: OrbitSpacing.md) {
                    poster(item.posterURL)
                    Text(item.event.title)
                        .font(OrbitType.title)
                        .foregroundStyle(OrbitColors.text)
                    HStack(spacing: OrbitSpacing.sm) {
                        if item.isRegistered {
                            statusBadge("Registered")
                        }
                        if item.isSaved {
                            statusBadge("Saved")
                        }
                    }
                    labeled("Organizer", item.organizerName)
                    labeled("Venue", item.event.venue)
                    labeled("Starts", item.event.startsAt.formatted(Self.when))
                    labeled("Ends", item.event.endsAt.formatted(Self.when))
                    Text(item.event.description)
                        .font(OrbitType.body)
                        .foregroundStyle(OrbitColors.text)
                }
                .padding(OrbitSpacing.md)
            }
            .background(OrbitColors.background)
        }
    }

    @ViewBuilder
    private func poster(_ url: URL?) -> some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    posterPlaceholder
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: OrbitRadius.card, style: .continuous))
        } else {
            posterPlaceholder
        }
    }

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: OrbitRadius.card, style: .continuous)
            .fill(OrbitColors.secondaryBackground)
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .overlay {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(OrbitColors.secondaryText)
            }
            .accessibilityLabel("No poster")
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: OrbitSpacing.xs) {
            Text(title)
                .font(OrbitType.caption)
                .foregroundStyle(OrbitColors.secondaryText)
            Text(value)
                .font(OrbitType.body)
                .foregroundStyle(OrbitColors.text)
        }
    }

    private func statusBadge(_ title: String) -> some View {
        Text(title)
            .font(OrbitType.caption)
            .padding(.horizontal, OrbitSpacing.sm)
            .padding(.vertical, OrbitSpacing.xs)
            .background(OrbitColors.secondaryBackground)
            .clipShape(Capsule())
    }

    private static let when = Date.FormatStyle(date: .abbreviated, time: .shortened)
}
