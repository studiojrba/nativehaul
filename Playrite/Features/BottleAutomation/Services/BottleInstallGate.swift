import Foundation

/// Pure rules for whether to offer the Download button.
///
/// Order: only Steam games installed nowhere qualify → a blocking verdict hides the button (the verdict shows
/// instead, even without CrossOver) → CrossOver must be installed → enough free space for the game plus Steam →
/// a signed-in golden bottle to clone.
@MainActor
enum BottleInstallGate {
    /// Room for Steam itself and its updates, on top of the game.
    static let steamOverheadBytes: Int64 = 2_000_000_000
    private static let bytesPerGB = 1_000_000_000.0

    /// Availability for `game`. `availableBytes` is `nil` when free space couldn't be read.
    static func evaluate(
        _ game: Game,
        toolchain: CrossOverToolchain?,
        recipes: RecipeDatabase,
        availableBytes: Int64?,
        golden: GoldenBottleStatus
    ) -> InstallAvailability {
        guard let appID = game.steamAppID, game.steamInstalls.isEmpty, game.appBundlePath == nil else {
            return .notApplicable
        }
        let match = recipes.recipe(forSteamAppID: appID)
        if match.recipe.verdict.rating.blocksInstall {
            return .blocked(match.recipe.verdict)
        }
        guard toolchain != nil else { return .crossOverMissing }
        let gameBytes = game.installSizeBytes
            ?? Int64((match.recipe.installSizeGB ?? recipes.defaultRecipe.installSizeGB ?? 0) * bytesPerGB)
        let required = gameBytes + steamOverheadBytes
        if let availableBytes, availableBytes < required {
            return .insufficientSpace(required: required, available: availableBytes)
        }
        guard golden.isReady else { return .needsGoldenBottle(golden) }
        return .ready(match, requiredBytes: required, isSizeEstimated: game.installSizeBytes == nil)
    }
}
