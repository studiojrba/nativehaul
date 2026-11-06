import Foundation

/// One-click Windows installs through CrossOver, built on a golden bottle. Live: ``BottleInstallService``; mock:
/// ``MockBottleInstaller``.
@MainActor
protocol BottleInstalling: AnyObject {
    /// Golden bottle status (adopts a lean signed-in bottle automatically).
    func goldenStatus() -> GoldenBottleStatus
    /// Creates "Retriever Steam", installs Steam and waits for the one-time sign-in.
    func setUpGoldenBottle(onStage: @escaping @MainActor (BottleInstallStage) -> Void) async
    /// Whether to offer Download for `game`, and if not, why.
    func availability(for game: Game) -> InstallAvailability
    /// Clones the golden bottle for `game`, applies its recipe and installs it, reporting each stage. Ends with
    /// ``BottleInstallStage/installed`` or ``BottleInstallStage/failed(reason:)``.
    func install(_ game: Game, onStage: @escaping @MainActor (BottleInstallStage) -> Void) async
    /// Opens Steam in the game's bottle (or the golden bottle during setup) so the user can sign in there.
    func openSteam(for game: Game?)
}
