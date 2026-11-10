import Foundation

/// The versioned recipe database. Ships bundled as `BottleRecipes.json`; the format is plain JSON so it can be
/// extended by the community later (a downloaded or local override would decode the same shape).
struct RecipeDatabase: Codable, Equatable, Sendable {
    /// The format version this build understands.
    static let supportedSchemaVersion = 1

    /// Format version.
    let schemaVersion: Int
    /// Content version (date-style, for example "2026.11.06").
    let databaseVersion: String
    /// Used for any game without its own recipe.
    let defaultRecipe: GameRecipe
    /// Per-game recipes.
    let recipes: [GameRecipe]

    /// The recipe for `steamAppID`, or the default.
    func recipe(forSteamAppID steamAppID: Int) -> RecipeMatch {
        if let recipe = recipes.first(where: { $0.steamAppID == steamAppID }) {
            return RecipeMatch(recipe: recipe, isDefault: false)
        }
        return RecipeMatch(recipe: defaultRecipe, isDefault: true)
    }

    /// Decodes a database, refusing formats newer than this build understands.
    static func decode(_ data: Data) throws -> RecipeDatabase {
        let database = try JSONDecoder().decode(RecipeDatabase.self, from: data)
        guard database.schemaVersion <= supportedSchemaVersion else {
            throw BottleInstallError.unsupportedRecipeDatabase(database.schemaVersion)
        }
        return database
    }
}
