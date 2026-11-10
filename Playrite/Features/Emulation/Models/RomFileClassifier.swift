import Foundation

/// Decides which system a ROM file belongs to. Unique extensions decide alone; shared ones (`.iso`, `.chd`, …) need a
/// folder name that says the system ("PS2", "GameCube", …), otherwise the file is left out rather than guessed.
enum RomFileClassifier {
    private static let unique: [String: EmulatedSystem] = [
        "gb": .gameBoy, "gbc": .gameBoyColor, "gba": .gameBoyAdvance, "nes": .nes, "sfc": .snes, "smc": .snes,
        "n64": .nintendo64, "z64": .nintendo64, "v64": .nintendo64, "nds": .nintendoDS, "gcm": .gameCube,
        "wbfs": .wii, "cso": .psp, "md": .genesis, "gen": .genesis, "smd": .genesis,
    ]
    /// Extensions several systems use. `.bin` is deliberately absent: it is a `.cue`'s data track.
    static let shared: Set<String> = ["iso", "chd", "cue", "rvz", "gcz", "pbp"]
    /// Folder-name keywords, most specific first (so "PlayStation 2" isn't read as "PlayStation").
    private static let keywords: [(String, EmulatedSystem)] = [
        ("playstation2", .playStation2), ("ps2", .playStation2), ("psp", .psp), ("playstationportable", .psp),
        ("playstation", .playStation), ("psx", .playStation), ("ps1", .playStation), ("gamecube", .gameCube),
        ("ngc", .gameCube), ("wii", .wii),
    ]

    /// Every extension NX Shelf looks for.
    static var extensions: Set<String> {
        Set(unique.keys).union(shared)
    }

    /// The system for the file at `path`, or `nil` when unknown or ambiguous.
    static func system(forFileAt path: String) -> EmulatedSystem? {
        let ext = (path as NSString).pathExtension.lowercased()
        if let system = unique[ext] {
            return system
        }
        guard shared.contains(ext) else { return nil }
        let folders = (path as NSString).deletingLastPathComponent.split(separator: "/").reversed()
        for folder in folders {
            let key = TitleNormalizer.key(for: String(folder))
            if key == "wiiu" {
                return nil
            }
            if key == "gc" {
                return .gameCube
            }
            if let match = keywords.first(where: { key.contains($0.0) }) {
                return match.1
            }
        }
        return nil
    }

    /// A display title from a ROM file name: the extension and No-Intro style tags ("(USA)", "[!]") removed.
    static func title(forFileAt path: String) -> String {
        let name = ((path as NSString).lastPathComponent as NSString).deletingPathExtension
        let stripped = name.replacingOccurrences(
            of: "\\s*[\\(\\[][^\\)\\]]*[\\)\\]]",
            with: "",
            options: .regularExpression
        )
        let cleaned = stripped.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? name : cleaned
    }
}
