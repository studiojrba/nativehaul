import SwiftUI

/// "New in Downloads": game files found in the watched folder, each with what was understood and a Queue button.
/// No file picker anywhere; nothing builds until Queue is clicked (ADR 0024).
struct BuildsInboxSection: View {
    /// Inbox state.
    let inbox: BuildsInboxViewModel

    var body: some View {
        Section {
            Text(BuildsInboxViewModel.watchingNote(folderName: inbox.folderName))
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            if inbox.items.isEmpty {
                Text("No new game files.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(inbox.items) { item in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    DetectedGameRow(game: item, isSelectable: false, isSelected: false) {}
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Button("Queue", systemImage: "plus") { inbox.queue(item) }
                        Button("Dismiss") { inbox.dismiss(item) }
                    }
                }
            }
        } header: {
            HStack {
                Text(inbox.title)
                Spacer()
                Button("Refresh", systemImage: "arrow.clockwise") { inbox.refresh() }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let inbox = environment.makeBuildsInboxViewModel(queue: environment.makeNXNativeViewModel {})
    List { BuildsInboxSection(inbox: inbox) }
        .onAppear { inbox.start() }
}
