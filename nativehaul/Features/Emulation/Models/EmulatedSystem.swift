import Foundation

/// A console whose games run in an emulator. nativehaul only routes to the emulator; it never emulates.
enum EmulatedSystem: String, Codable, CaseIterable, Identifiable, Sendable {
    case gameBoy
    case gameBoyColor
    case gameBoyAdvance
    case nes
    case snes
    case nintendo64
    case nintendoDS
    case gameCube
    case wii
    case playStation
    case playStation2
    case psp
    case genesis

    /// Stable identity.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .gameBoy: "Game Boy"
        case .gameBoyColor: "Game Boy Color"
        case .gameBoyAdvance: "Game Boy Advance"
        case .nes: "NES"
        case .snes: "Super NES"
        case .nintendo64: "Nintendo 64"
        case .nintendoDS: "Nintendo DS"
        case .gameCube: "GameCube"
        case .wii: "Wii"
        case .playStation: "PlayStation"
        case .playStation2: "PlayStation 2"
        case .psp: "PSP"
        case .genesis: "Genesis / Mega Drive"
        }
    }

    /// The RetroArch core used by default (macOS core file name without `.dylib`), or `nil` when RetroArch isn't
    /// the right default for this system.
    var retroArchCore: String? {
        switch self {
        case .gameBoy, .gameBoyColor: "gambatte_libretro"
        case .gameBoyAdvance: "mgba_libretro"
        case .nes: "nestopia_libretro"
        case .snes: "snes9x_libretro"
        case .nintendo64: "mupen64plus_next_libretro"
        case .nintendoDS: "melonds_libretro"
        case .gameCube, .wii: "dolphin_libretro"
        case .playStation: "pcsx_rearmed_libretro"
        case .psp: "ppsspp_libretro"
        case .genesis: "genesis_plus_gx_libretro"
        case .playStation2: nil
        }
    }
}
