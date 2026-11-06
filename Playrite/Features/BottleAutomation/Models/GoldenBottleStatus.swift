import Foundation

/// Whether the golden bottle is ready, and if not, what's missing. Retriever treats "signed in to Steam in
/// Retriever + CrossOver installed + a signed-in golden bottle" as standing consent to install games in new bottles.
/// A lean bottle already signed in to the linked account is adopted automatically (zero-tinker, ADR 0017).
enum GoldenBottleStatus: Equatable, Sendable {
    /// No Steam account is linked in Retriever (Settings → Steam).
    case steamNotLinked
    /// CrossOver isn't installed.
    case crossOverMissing
    /// No signed-in bottle yet; Retriever can create "Retriever Steam".
    case notSetUp
    /// A signed-in bottle was found, but it has games installed, so cloning it would copy them all.
    case foundButNotLean(bottleName: String)
    /// Ready: new games are cloned from this bottle.
    case ready(bottleName: String)

    /// Whether Download can proceed without further setup.
    var isReady: Bool {
        if case .ready = self {
            true
        } else {
            false
        }
    }
}
