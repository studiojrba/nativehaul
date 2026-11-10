import SwiftUI

/// One numbered instruction in the API key step.
struct SteamNumberedStep<Content: View>: View {
    /// Step number.
    let number: Int
    /// Instruction.
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
            Text("\(number).").font(DesignTokens.Typography.headline).monospacedDigit()
            content().fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SteamNumberedStep(number: 3) { Text("Copy the key Steam shows you.") }
        .padding(DesignTokens.Spacing.lg)
}
