import SwiftUI

/// Sheet for adding a game manually.
struct AddGameSheet: View {
    /// Called with the entered values when the user confirms.
    let onAdd: (String, GamePlatform, GameStatus) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var platform: GamePlatform = .macNative
    @State private var status: GameStatus = .backlog

    var body: some View {
        Form {
            TextField("Title", text: $title)
            Picker("Platform", selection: $platform) {
                ForEach(GamePlatform.allCases) { Text($0.displayName).tag($0) }
            }
            Picker("Status", selection: $status) {
                ForEach(GameStatus.allCases) { Text($0.displayName).tag($0) }
            }
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onAdd(title, platform, status)
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

#Preview {
    AddGameSheet { _, _, _ in }
}
