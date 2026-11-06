import Foundation

/// How to run games in one emulator app: where to find it, which systems it handles, and its launch arguments.
///
/// `{rom}` in ``argumentTemplate`` becomes the ROM path and `{core}` the RetroArch core path. Only emulators whose
/// command-line launch syntax is documented are seeded (``EmulatorCatalog``); the model is open for more.
struct EmulatorProfile: Codable, Equatable, Identifiable, Sendable {
    /// Stable ID ("retroarch").
    let id: String
    /// Display name.
    let name: String
    /// App bundle file name ("RetroArch.app").
    let appName: String
    /// Systems it can run.
    let systems: [EmulatedSystem]
    /// Arguments with `{rom}` / `{core}` placeholders.
    let argumentTemplate: [String]
    /// Whether it needs a libretro core per system (RetroArch).
    let usesCores: Bool
    /// The emulator's official download page (for the "isn't installed" state).
    let homepage: URL?
    /// A BIOS the user must provide for some systems, if any.
    let biosRequirement: BiosRequirement?

    /// Arguments for a launch.
    func arguments(romPath: String, corePath: String?) -> [String] {
        argumentTemplate.map {
            $0.replacingOccurrences(of: "{rom}", with: romPath).replacingOccurrences(of: "{core}", with: corePath ?? "")
        }
    }
}
