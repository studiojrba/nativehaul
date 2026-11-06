import SwiftUI

/// Generic sheet asking for a single name (used for new series and collections).
struct NameEntrySheet<Extra: View>: View {
    /// Sheet title.
    let title: String
    /// Extra form rows shown under the name field.
    let extra: Extra
    /// Called with the entered name.
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""

    var body: some View {
        Form {
            Text(title).font(DesignTokens.Typography.headline)
            TextField("Name", text: $name)
            extra
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    onSave(name)
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

extension NameEntrySheet where Extra == EmptyView {
    /// Creates a sheet with only a name field.
    init(title: String, onSave: @escaping (String) -> Void) {
        self.init(title: title, extra: EmptyView(), onSave: onSave)
    }
}

#Preview {
    NameEntrySheet(title: "New Series") { _ in }
}
