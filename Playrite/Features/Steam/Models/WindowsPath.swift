import Foundation

/// Converts between Windows paths inside a CrossOver bottle and macOS paths.
enum WindowsPath {
    private static let systemDrive = "c"
    private static let driveSeparator: Character = ":"
    private static let driveAndRest = 2

    /// macOS path for a Windows path like `D:\Games\SteamLibrary`. `C:` maps to `drive_c`; other letters go through
    /// the bottle's `dosdevices/<letter>:` link. Returns `nil` for paths without a drive letter.
    static func macPath(for windowsPath: String, inBottle bottlePath: String) -> String? {
        let normalized = windowsPath.replacingOccurrences(of: "\\", with: "/")
        let parts = normalized.split(separator: driveSeparator, maxSplits: 1)
        guard parts.count == driveAndRest, let letter = parts.first?.lowercased(), letter.count == 1 else { return nil }
        let rest = String(parts[1]).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let drive = letter == systemDrive ? "drive_c" : "dosdevices/\(letter):"
        let base = (bottlePath as NSString).appendingPathComponent(drive)
        return rest.isEmpty ? base : (base as NSString).appendingPathComponent(rest)
    }

    /// Windows path (`C:\…`) for a macOS path inside the bottle's `drive_c`, or `nil` when outside it.
    static func windowsPath(for macPath: String, inBottle bottlePath: String) -> String? {
        let driveC = (bottlePath as NSString).appendingPathComponent("drive_c")
        guard macPath == driveC || macPath.hasPrefix(driveC + "/") else { return nil }
        let rest = String(macPath.dropFirst(driveC.count)).replacingOccurrences(of: "/", with: "\\")
        return "C:" + (rest.isEmpty ? "\\" : rest)
    }
}
