import Foundation

/// Finds installed Steam games on this Mac and in CrossOver bottles. Read-only.
/// Live: ``SteamInstallScanner``; mock: ``MockSteamInstallScanner``.
protocol SteamInstallScanning: Sendable {
    /// Every installed app, one entry per (app, location).
    func scanInstalls(roots: SteamInstallRoots) -> [SteamInstalledApp]
}
