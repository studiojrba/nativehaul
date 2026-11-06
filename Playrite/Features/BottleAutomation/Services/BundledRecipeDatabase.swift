import Foundation

/// Loads `BottleRecipes.json` from the app bundle.
enum BundledRecipeDatabase {
    private static let resourceName = "BottleRecipes"

    /// The bundled database. Falls back to a single conservative default if the file is missing or unreadable, so
    /// the app never offers settings it can't explain.
    static func load(bundle: Bundle = .main) -> RecipeDatabase {
        guard let url = bundle.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let database = try? RecipeDatabase.decode(data)
        else { return fallback }
        return database
    }

    /// Used only when the bundled file can't be read.
    static let fallback = RecipeDatabase(
        schemaVersion: RecipeDatabase.supportedSchemaVersion,
        databaseVersion: "fallback",
        defaultRecipe: GameRecipe(
            steamAppID: nil,
            title: "Default",
            bottleTemplate: .win10,
            graphicsBackend: .d3dMetal,
            syncMode: .msync,
            environment: [:],
            notes: "General starting point.",
            verdict: CompatibilityVerdict(rating: .untested, reason: "No recipe database was available."),
            installSizeGB: nil
        ),
        recipes: []
    )
}
