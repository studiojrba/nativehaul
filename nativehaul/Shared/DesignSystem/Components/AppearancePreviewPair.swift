import SwiftUI

/// Shows the same content in the light and dark appearance side by side, each on its own paper (for `#Preview`s).
struct AppearancePreviewPair<Content: View>: View {
    /// The content to show twice.
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 0) {
            ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
                content()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.paper)
                    .environment(\.colorScheme, scheme)
            }
        }
    }
}

#Preview {
    AppearancePreviewPair {
        Text("Paper and ink").foregroundStyle(Theme.ink).padding(DesignTokens.Spacing.xl)
    }
}
