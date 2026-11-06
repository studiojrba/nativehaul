import Foundation

/// A BIOS an emulator needs, which only the user can provide from their own console.
struct BiosRequirement: Codable, Equatable, Sendable {
    /// Systems that need it.
    let systems: [EmulatedSystem]
    /// Folder the emulator reads BIOS files from (tilde allowed).
    let folder: String
    /// What to call it in the prompt ("PlayStation 2 BIOS").
    let displayName: String

    /// The file prompt for this BIOS.
    var request: UserFileRequest {
        UserFileRequest(
            fileDescription: displayName,
            reason: "The emulator needs it to start \(systems.map(\.displayName).joined(separator: " and ")) games.",
            destinationFolder: folder
        )
    }
}
