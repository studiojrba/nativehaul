import SwiftUI

/// A spinner with a line of text, for component install steps.
struct ComponentProgressRow: View {
    /// What is happening.
    let text: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ProgressView().controlSize(.small)
            Text(text)
        }
    }
}

#Preview {
    ComponentProgressRow(text: "Unpacking…").padding(DesignTokens.Spacing.lg)
}
