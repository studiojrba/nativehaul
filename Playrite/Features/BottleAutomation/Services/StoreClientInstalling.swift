import Foundation

/// A store client that lives inside a bottle. Slice 1 has ``SteamBottleClient``; Epic and GOG clients would
/// implement the same steps later.
///
/// The user signs in to the client themselves, in the client's own window. Retriever never asks for, sees or stores
/// store credentials; it only checks which account ID the client remembers.
protocol StoreClientInstalling: Sendable {
    /// Installs the store client into the bottle (no-op when already there).
    func installClient(in plan: BottlePlan, toolchain: CrossOverToolchain) async throws
    /// Opens the client's window in the bottle so the user can sign in.
    func openClient(in plan: BottlePlan, toolchain: CrossOverToolchain) throws
    /// The account the bottle's client last signed in with (an opaque store ID, never a credential).
    func signedInAccountID(in plan: BottlePlan) -> String?
    /// Asks the client to install the game.
    func startInstall(_ game: StoreGameReference, in plan: BottlePlan, toolchain: CrossOverToolchain) throws
    /// Current install progress, or `nil` before the client has started.
    func installProgress(_ game: StoreGameReference, in plan: BottlePlan) -> StoreInstallProgress?
}
