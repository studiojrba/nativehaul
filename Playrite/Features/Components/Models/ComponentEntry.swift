import Foundation

/// One managed component (an emulator app) in the catalog.
struct ComponentEntry: Codable, Equatable, Identifiable, Sendable {
    /// Matches the ``EmulatorProfile`` ID it backs.
    let id: String
    /// Display name.
    let name: String
    /// The `.app` inside the download.
    let appName: String
    /// Official source.
    let source: ComponentSource
    /// What the download is.
    let installMethod: ComponentInstallMethod
    /// Where it's installed (tilde allowed; `~/Applications` needs no admin prompt).
    let destination: String
    /// Release-notes or project page.
    let homepage: URL?

    /// Where the installed app lives.
    var installedPath: String {
        ((destination as NSString).expandingTildeInPath as NSString).appendingPathComponent(appName)
    }
}
