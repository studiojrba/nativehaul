import SwiftUI

/// Sheet for entering HowLongToBeat figures (in hours) that the user looked up.
struct HLTBEntrySheet: View {
    /// Initial values.
    let initial: HLTBEstimate?
    /// Called with hours per category.
    let onSave: ([HLTBCategory: Double]) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var hours: [HLTBCategory: Double] = [:]

    var body: some View {
        Form {
            ForEach(HLTBCategory.allCases) { category in
                TextField(category.displayName, value: binding(for: category), format: .number)
            }
            TagLabel(text: HLTBEstimate.label, symbolName: PlaytimeSource.hltbEstimate.symbolName, tint: Theme.estimate)
            Text(
                "These are community estimates from HowLongToBeat.com, not your playtime. "
                    + "They never count toward stats or badges."
            )
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(Theme.secondaryText)
        }
        .formStyle(.grouped)
        .padding(DesignTokens.Spacing.lg)
        .frame(minWidth: DesignTokens.Layout.detailMinWidth)
        .onAppear {
            hours = (initial?.seconds ?? [:]).mapValues(DurationFormatting.hours(seconds:))
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(hours)
                    dismiss()
                }
            }
        }
    }

    private func binding(for category: HLTBCategory) -> Binding<Double> {
        Binding(get: { hours[category] ?? 0 }, set: { hours[category] = $0 })
    }
}

#Preview {
    HLTBEntrySheet(initial: nil) { _ in }
}
