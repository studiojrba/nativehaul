import Foundation

/// Reads the real volumes for the install step (spec §3.6, §6: real free space, an external drive only when one is
/// actually mounted). Live: ``LiveVolumeInspector``; mock: ``MockVolumeInspector``.
protocol VolumeInspecting: Sendable {
    /// The volume holding `path` (or its nearest existing parent).
    func volume(containing path: String) -> VolumeInfo?
    /// Writable external drives mounted right now (not the startup disk, not disk images or network shares).
    func externalVolumes() -> [VolumeInfo]
}
