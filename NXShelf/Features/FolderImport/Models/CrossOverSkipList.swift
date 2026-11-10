import Foundation

/// Explicit rules for ignoring non-game folders and executables inside CrossOver bottles.
///
/// Kept deliberately small and literal so it is easy to audit; covered by `CrossOverSkipListTests`.
enum CrossOverSkipList {
    /// `Program Files` folders that are Windows/Wine components, runtimes or store launchers — never games.
    static let folderNames: Set = [
        "common files", "internet explorer", "microsoft", "microsoft.net", "msbuild", "reference assemblies",
        "windows defender", "windows mail", "windows media player", "windows nt", "windows photo viewer",
        "windows portable devices", "windows sidebar", "windowsapps", "windowspowershell", "uninstall information",
        "installshield installation information", "mono", "gecko", "dotnet", "directx", "steam", "epic games",
        "gog galaxy", "ubisoft", "ea", "ea games", "electronic arts", "origin", "battle.net", "amazon games",
        "rockstar games launcher", "xbox", "nvidia corporation", "amd", "codeweavers",
    ]

    /// Substrings that mark a folder as an installer, redistributable or crash helper.
    static let folderFragments = ["redist", "setup", "installer", "uninstall", "crash", "support tools"]

    /// Substrings that disqualify an `.exe` as the game executable.
    static let executableFragments = [
        "unins", "setup", "install", "redist", "vcredist", "dxsetup", "dotnet", "crash", "report", "update",
        "patcher", "helper", "launcherhelper", "easyanticheat", "battleye", "cefprocess", "webhelper", "service",
    ]

    /// Whether a top-level `Program Files` folder should be ignored.
    static func shouldSkipFolder(named name: String) -> Bool {
        let lowered = name.lowercased()
        return folderNames.contains(lowered) || folderFragments.contains { lowered.contains($0) }
    }

    /// Whether an executable filename is a plausible game binary.
    static func isPlausibleGameExecutable(_ filename: String) -> Bool {
        let lowered = filename.lowercased()
        guard lowered.hasSuffix(".exe") else { return false }
        return !executableFragments.contains { lowered.contains($0) }
    }
}
