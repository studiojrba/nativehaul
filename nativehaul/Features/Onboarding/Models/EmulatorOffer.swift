import Foundation

/// An emulator nativehaul can set up from its official source during onboarding (one ``ComponentEntry`` that isn't on
/// this Mac yet), with its version and source said plainly.
struct EmulatorOffer: Identifiable, Equatable, Sendable {
    /// The catalog entry.
    let entry: ComponentEntry
    /// Ticked by default when nothing is on this Mac yet.
    let isRecommended: Bool

    /// The emulators ticked by default when none are found.
    static let recommendedIDs: Set<String> = ["retroarch", "dolphin"]

    /// Stable identity (the component ID).
    var id: String {
        entry.id
    }

    /// "Version 1.19.1" for a pinned download, "Latest release" for a GitHub source.
    var versionLabel: String {
        switch entry.source {
        case let .pinned(_, version, _): "Version \(version)"
        case .gitHub: "Latest release"
        }
    }

    /// Where it comes from: "GitHub · melonDS-emu/melonDS" or the official download host.
    var sourceLabel: String {
        switch entry.source {
        case let .gitHub(owner, repo, _): "GitHub · \(owner)/\(repo)"
        case let .pinned(url, _, _): url.host() ?? url.absoluteString
        }
    }
}
