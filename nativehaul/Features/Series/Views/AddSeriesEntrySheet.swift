import SwiftUI

/// Sheet for appending a game or sub-game to a series with its part label.
struct AddSeriesEntrySheet: View {
    /// Selectable items.
    let candidates: [SeriesEntryCandidate]
    /// Called with the chosen item and part label.
    let onAdd: (SeriesEntryCandidate, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: UUID?
    @State private var partLabel = ""

    var body: some View {
        Form {
            Picker("Game", selection: $selectedID) {
                Text("Choose…").tag(UUID?.none)
                ForEach(candidates) { Text($0.title).tag(Optional($0.id)) }
            }
            TextField("Part label (e.g. 1, 2, Zero)", text: $partLabel)
            Text("Part labels are kept exactly as entered and are never renumbered.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if let candidate = candidates.first(where: { $0.id == selectedID }) {
                        onAdd(candidate, partLabel)
                    }
                    dismiss()
                }
                .disabled(selectedID == nil || partLabel.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    AddSeriesEntrySheet(candidates: [.game(Game(title: "Tideborn"))]) { _, _ in }
}
