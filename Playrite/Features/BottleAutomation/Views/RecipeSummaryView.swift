import SwiftUI

/// What one click will do: the recipe, its verdict and notes, and the space it needs.
struct RecipeSummaryView: View {
    /// The recipe chosen.
    let match: RecipeMatch
    /// Space needed (game + Steam).
    let requiredBytes: Int64
    /// Whether the game's size is an estimate.
    let isSizeEstimated: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Installs into its own CrossOver bottle with \(match.recipe.summary).")
            if match.isDefault {
                Text("No recipe for this game yet — using the general default.")
            } else {
                Text("\(match.recipe.verdict.rating.displayName): \(match.recipe.verdict.reason)")
            }
            if !match.recipe.notes.isEmpty, !match.isDefault {
                Text(match.recipe.notes)
            }
            Text("Needs about \(ByteText.text(requiredBytes))\(isSizeEstimated ? " (estimate)" : "") free.")
        }
        .font(DesignTokens.Typography.caption)
        .foregroundStyle(Theme.secondaryText)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    RecipeSummaryView(
        match: BundledRecipeDatabase.load().recipe(forSteamAppID: 1_245_620),
        requiredBytes: 62_000_000_000,
        isSizeEstimated: true
    )
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}
