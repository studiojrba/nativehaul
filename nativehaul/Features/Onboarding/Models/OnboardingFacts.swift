import Foundation

/// The real state the conversation talks about (spec §3.6, §6): read once at the start and updated by each answer.
struct OnboardingFacts: Equatable, Sendable {
    /// Game folders already set up (the replay).
    var configuredFolders: [String] = []
    /// A usual games folder that exists on this Mac and isn't set up yet (`~/Games`, `~/Switch/Games`).
    var suggestedFolder: String?
    /// The folder(s) just scanned, for display.
    var scannedFolderLabel: String?
    /// What the scan found.
    var scan: OnboardingScan?
    /// Where Switch builds go now.
    var installLocation = ""
    /// The volume holding it.
    var installVolume: VolumeInfo?
    /// An external drive, when one is mounted.
    var externalVolume: VolumeInfo?
    /// Whether the user picked the external drive.
    var usesExternal = false
    /// The library key already on this Mac, if found (detected, not re-demanded — ADR 0021).
    var detectedKeys: String?
    /// What happened at the keys step.
    var keysOutcome: KeysOutcome?
    /// Players found.
    var players: [DetectedPlayer] = []
    /// Emulators that can be set up from their official sources (not on this Mac yet).
    var emulatorOffers: [EmulatorOffer] = []
    /// The mode chosen at the couch-or-desk beat.
    var chosenMode: AppMode?
    /// FileVault, for the couch note.
    var fileVault = FileVaultStatus.unknown

    /// The emulators found (players other than the build engine).
    var emulators: [DetectedPlayer] {
        players.filter { $0.kind != .buildEngine }
    }
}
