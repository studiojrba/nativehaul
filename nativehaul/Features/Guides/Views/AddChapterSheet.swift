import SwiftUI

/// Sheet for adding a chapter link to a guide.
struct AddChapterSheet: View {
    /// Guide the chapter belongs to.
    let guideTitle: String
    /// Returns `true` when accepted.
    let onAdd: (String, String) -> Bool
    /// Validation message from the last attempt.
    let errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var url = ""

    var body: some View {
        Form {
            Text(guideTitle).font(DesignTokens.Typography.headline)
            TextField("Chapter title", text: $title)
            TextField("Chapter link (same guide)", text: $url)
            if let errorMessage {
                Text(errorMessage).foregroundStyle(Theme.danger)
            }
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    if onAdd(title, url) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddChapterSheet(guideTitle: "Walkthrough", onAdd: { _, _ in true }, errorMessage: nil)
}
