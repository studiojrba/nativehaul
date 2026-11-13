import Foundation

/// One real game found by the onboarding scan, for the shelf scene.
struct ScanCover: Identifiable, Equatable, Sendable {
    /// The game's ID.
    let id: UUID
    /// Its title.
    let title: String
    /// Its cover art on disk, if any yet.
    let imagePath: String?
    /// What sits together in its folder ("Base + update + 2 DLC"), when the folder scan sorted it.
    var contents: ScanContents?
}
