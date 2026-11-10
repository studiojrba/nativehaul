import SwiftUI

/// Sheet for linking a GameFAQs guide. Title and author are required for attribution.
struct AddGuideSheet: View {
    /// Returns `true` when the guide was accepted.
    let onAdd: (String, String, String) -> Bool
    /// Validation message from the last attempt.
    let errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var author = ""
    @State private var url = ""

    var body: some View {
        Form {
            TextField("Guide title", text: $title)
            TextField("Author", text: $author)
            TextField("https://gamefaqs.gamespot.com/…/faqs/…", text: $url)
            Text(
                "NX Shelf only stores the link and credits the author. Guides open in your browser; nothing is copied."
            )
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(Theme.secondaryText)
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
                    if onAdd(title, author, url) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddGuideSheet(onAdd: { _, _, _ in true }, errorMessage: nil)
}
