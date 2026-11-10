import Foundation

/// Seeded emulator profiles and the default system → emulator mapping.
///
/// Seeds are limited to emulators whose command-line launch syntax is documented: RetroArch (`-L <core> <rom>`),
/// Dolphin (`-e <rom>`), PCSX2 (`-- <rom>`), melonDS and PPSSPP (ROM path as the only argument).
enum EmulatorCatalog {
    private static let retroArchCores = "~/Library/Application Support/RetroArch/cores"

    /// All seeded profiles.
    static let profiles: [EmulatorProfile] = [retroArch, dolphin, pcsx2, melonDS, ppsspp]

    /// RetroArch with a core per system.
    static let retroArch = EmulatorProfile(
        id: "retroarch", name: "RetroArch", appName: "RetroArch.app",
        systems: EmulatedSystem.allCases.filter { $0.retroArchCore != nil },
        argumentTemplate: ["-L", "{core}", "{rom}"], usesCores: true,
        homepage: URL(string: "https://www.retroarch.com/?page=platforms"), biosRequirement: nil
    )
    /// Dolphin (GameCube, Wii).
    static let dolphin = EmulatorProfile(
        id: "dolphin", name: "Dolphin", appName: "Dolphin.app", systems: [.gameCube, .wii],
        argumentTemplate: ["-e", "{rom}"], usesCores: false,
        homepage: URL(string: "https://dolphin-emu.org/download/"), biosRequirement: nil
    )
    /// PCSX2 (PlayStation 2). Needs the user's own console BIOS.
    static let pcsx2 = EmulatorProfile(
        id: "pcsx2", name: "PCSX2", appName: "PCSX2.app", systems: [.playStation2],
        argumentTemplate: ["--", "{rom}"], usesCores: false,
        homepage: URL(string: "https://pcsx2.net/downloads/"),
        biosRequirement: BiosRequirement(
            systems: [.playStation2],
            folder: "~/Library/Application Support/PCSX2/bios",
            displayName: "PlayStation 2 BIOS"
        )
    )
    /// melonDS (Nintendo DS).
    static let melonDS = EmulatorProfile(
        id: "melonds", name: "melonDS", appName: "melonDS.app", systems: [.nintendoDS],
        argumentTemplate: ["{rom}"], usesCores: false,
        homepage: URL(string: "https://melonds.kuribo64.net/downloads.php"), biosRequirement: nil
    )
    /// PPSSPP (PSP).
    static let ppsspp = EmulatorProfile(
        id: "ppsspp", name: "PPSSPP", appName: "PPSSPP.app", systems: [.psp],
        argumentTemplate: ["{rom}"], usesCores: false,
        homepage: URL(string: "https://www.ppsspp.org/download/"), biosRequirement: nil
    )

    /// Default emulator for a system: RetroArch wherever it has a core, PCSX2 for PlayStation 2.
    static func defaultProfile(for system: EmulatedSystem) -> EmulatorProfile {
        system.retroArchCore == nil ? pcsx2 : retroArch
    }

    /// Profiles able to run `system`, default first.
    static func profiles(for system: EmulatedSystem) -> [EmulatorProfile] {
        let all = profiles.filter { $0.systems.contains(system) }
        let preferred = defaultProfile(for: system)
        return [preferred] + all.filter { $0.id != preferred.id }
    }

    /// A profile by ID.
    static func profile(id: String) -> EmulatorProfile? {
        profiles.first { $0.id == id }
    }

    /// Where RetroArch keeps `core` (expanded).
    static func corePath(_ core: String) -> String {
        ((retroArchCores as NSString).expandingTildeInPath as NSString).appendingPathComponent("\(core).dylib")
    }
}
