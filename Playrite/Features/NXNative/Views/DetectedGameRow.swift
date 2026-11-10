import SwiftUI

/// One game Add Build found: name, title ID and what was understood ("Base game · update v65536 · 3 DLC").
struct DetectedGameRow: View {
    /// The game.
    let game: DetectedGame
    /// Whether a checkbox is shown (several games in one folder).
    let isSelectable: Bool
    /// Whether it is chosen for the queue.
    let isSelected: Bool
    /// Toggles the choice.
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            if isSelectable {
                Toggle(game.name, isOn: Binding(get: { isSelected }, set: { _ in onToggle() }))
                    .labelsHidden()
                    .toggleStyle(.checkbox)
            }
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(game.name).font(DesignTokens.Typography.headline)
                if !game.titleID.isEmpty {
                    Text(game.titleID).font(DesignTokens.Typography.figuresSmall)
                        .foregroundStyle(Theme.secondaryText)
                }
                Text(game.details).foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    DetectedGameRow(
        game: DetectedGame(
            sourcePath: "/Users/demo/Downloads/Tideborn",
            name: "Tideborn",
            titleID: "0100ABCD00010000",
            details: "Base game · update v65536 · 3 DLC",
            isSwitch2: false
        ),
        isSelectable: true,
        isSelected: true
    ) {}
        .padding(DesignTokens.Spacing.lg)
}
