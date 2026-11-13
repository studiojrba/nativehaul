import SwiftUI

/// A status dot and its text (spec §3.3 Build status): the ready green when ready, the accent otherwise.
struct StatusDot: View {
    /// The text.
    let text: String
    /// Whether the status is ready (green) rather than in need of attention (accent).
    let isReady: Bool

    var body: some View {
        HStack(spacing: ShellLayout.Detail.statusGap) {
            Circle()
                .fill(isReady ? Theme.readyDot : Theme.accent)
                .frame(width: ShellLayout.Detail.statusDot, height: ShellLayout.Detail.statusDot)
            Text(text)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            StatusDot(text: "Ready to play", isReady: true)
            StatusDot(text: "Building now", isReady: false)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
