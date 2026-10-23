import SwiftUI

struct FeedView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var model: FeedViewModel?

    var body: some View {
        Group {
            if let model {
                feedContent(model)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Feed")
        .task {
            if model == nil {
                model = FeedViewModel(events: environment.events)
            }
            await model?.load()
        }
    }

    @ViewBuilder
    private func feedContent(_ model: FeedViewModel) -> some View {
        Group {
            if model.isLoading && model.loaded.isEmpty {
                ProgressView("Loading campus events")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = model.errorMessage, model.loaded.isEmpty {
                ContentUnavailableView {
                    Label("Couldn’t load feed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        Task { await model.load() }
                    }
                }
            } else if model.showsEmptyCampus {
                OrbitPlaceholder(
                    title: "No campus events yet",
                    systemImage: "calendar.badge.exclamationmark",
                    message: "Approved events will show up here."
                )
            } else if model.showsEmptySearch {
                OrbitPlaceholder(
                    title: "No matching events",
                    systemImage: "magnifyingglass",
                    message: "Try a different search."
                )
            } else {
                List(model.visibleEvents) { row in
                    NavigationLink(value: row.id) {
                        FeedEventRow(item: row)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: OrbitSpacing.sm,
                        leading: OrbitSpacing.md,
                        bottom: OrbitSpacing.sm,
                        trailing: OrbitSpacing.md
                    ))
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
        }
        .searchable(
            text: Binding(
                get: { model.query },
                set: { model.query = $0 }
            ),
            prompt: "Search events"
        )
        .refreshable {
            await model.load()
        }
        .navigationDestination(for: UUID.self) { eventId in
            EventDetailView(eventId: eventId)
        }
    }
}

private struct FeedEventRow: View {
    let item: EventWithMeta

    var body: some View {
        OrbitCard {
            VStack(alignment: .leading, spacing: OrbitSpacing.xs) {
                Text(item.event.title)
                    .font(OrbitType.headline)
                    .foregroundStyle(OrbitColors.text)
                Text(item.event.venue)
                    .font(OrbitType.body)
                    .foregroundStyle(OrbitColors.secondaryText)
                Text(item.event.startsAt, format: Self.when)
                    .font(OrbitType.caption)
                    .foregroundStyle(OrbitColors.secondaryText)
                Text(item.organizerName)
                    .font(OrbitType.caption)
                    .foregroundStyle(OrbitColors.secondaryText)
            }
        }
    }

    private static let when = Date.FormatStyle(date: .abbreviated, time: .shortened)
}
