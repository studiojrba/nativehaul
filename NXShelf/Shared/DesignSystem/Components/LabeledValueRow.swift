import SwiftUI

/// A label/value row used in detail screens. Values are data, so they're mono (ADR 0037).
struct LabeledValueRow<Value: View>: View {
    /// Leading label.
    let label: String
    /// Trailing content.
    @ViewBuilder let value: () -> Value

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.md) {
            Text(label)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(Theme.secondaryText)
                .frame(width: DesignTokens.Layout.formLabelWidth, alignment: .leading)
            value()
                .font(DesignTokens.Typography.monospaced)
            Spacer(minLength: DesignTokens.Spacing.none)
        }
    }
}

#Preview {
    LabeledValueRow(label: "Platform") { Text("Switch (native port)") }
        .padding(DesignTokens.Spacing.lg)
}
