import Foundation

/// Whether a Download button is offered for a game, and if not, why.
enum InstallAvailability: Equatable, Sendable {
    /// Not applicable: not a Steam game, or already installed somewhere.
    case notApplicable
    /// CrossOver isn't installed; the button says so and links CodeWeavers.
    case crossOverMissing
    /// The recipe's verdict forbids it; the verdict is shown instead of a button.
    case blocked(CompatibilityVerdict)
    /// Not enough free disk space.
    case insufficientSpace(required: Int64, available: Int64)
    /// Everything else is fine, but the golden bottle isn't ready; the setup offer shows instead.
    case needsGoldenBottle(GoldenBottleStatus)
    /// Ready: one click installs.
    case ready(RecipeMatch, requiredBytes: Int64, isSizeEstimated: Bool)
}
