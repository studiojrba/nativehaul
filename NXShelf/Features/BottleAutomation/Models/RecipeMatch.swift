import Foundation

/// The recipe chosen for a game, and whether it is the fallback default.
struct RecipeMatch: Equatable, Sendable {
    /// The recipe.
    let recipe: GameRecipe
    /// `true` when no recipe exists for the game and the default is used.
    let isDefault: Bool
}
