import SwiftUI

/// One configured game folder with a remove button.
struct GameFolderRow: View {
    /// Folder path.
    let folder: String
    /// Called when the user removes the folder.
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "folder").foregroundStyle(Theme.secondaryText)
            Text(folder)
                .lineLimit(DesignTokens.Lines.single)
                .truncationMode(.middle)
            Spacer()
            Button("Remove", systemImage: "minus.circle", role: .destructive, action: onRemove)
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
        }
    }
}

#Preview {
    GameFolderRow(folder: "/Users/demo/Switch/Games") {}
        .padding(DesignTokens.Spacing.lg)
}
