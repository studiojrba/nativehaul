import SwiftUI

/// A label/value row used in detail screens.
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
            Spacer(minLength: DesignTokens.Spacing.none)
        }
    }
}

#Preview {
    LabeledValueRow(label: "Platform") { Text("Steam") }
        .padding(DesignTokens.Spacing.lg)
}
