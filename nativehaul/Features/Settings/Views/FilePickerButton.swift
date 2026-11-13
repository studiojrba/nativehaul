import SwiftUI
import UniformTypeIdentifiers

/// A pill that opens the native macOS open panel (folders only, or files of the given types) and hands back the pick.
/// The pick is the user's consent: nothing is read until they choose (ADR 0026).
struct FilePickerButton: View {
    /// The button title ("Change…", "Add…").
    let title: String
    /// What may be picked (`[.folder]` for folders only).
    let contentTypes: [UTType]
    /// Called with the picked item.
    let onPick: (URL) -> Void

    @State private var isPicking = false

    var body: some View {
        Button(title) { isPicking = true }
            .buttonStyle(CreamPillButtonStyle())
            .fileImporter(isPresented: $isPicking, allowedContentTypes: contentTypes) { result in
                if case let .success(url) = result {
                    onPick(url)
                }
            }
    }
}

#Preview {
    AppearancePreviewPair {
        FilePickerButton(title: "Change…", contentTypes: [.folder]) { _ in }
            .padding(DesignTokens.Spacing.xl)
    }
}
