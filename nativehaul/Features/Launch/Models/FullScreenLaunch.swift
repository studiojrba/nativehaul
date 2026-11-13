import Foundation

/// How a launch asks a game to open full screen or windowed (ADR 0052, ADR 0058). Pure, so it is tested without
/// launching.
///
/// - nxnative builds declare their runtime switches in `Info.plist` under `DMSettings`. When a build declares
///   `DM_FULLSCREEN`, nativehaul sets it in the launch environment: `1` for full screen, `0` for windowed.
/// - Emulators get their documented full-screen command-line flag in front of their other arguments.
/// - ``LaunchStyle/standard`` changes nothing, so desktop mode launches exactly as before.
///
/// To verify per build and per emulator on real hardware.
enum FullScreenLaunch {
    /// The nxnative switch for full screen.
    static let nxnativeFullScreenKey = "DM_FULLSCREEN"
    /// `DMSettings` in an nxnative build's Info.plist.
    static let settingsKey = "DMSettings"
    /// The environment-variable name inside each `DMSettings` entry.
    static let settingEnvironmentKey = "env"

    /// Each emulator's documented full-screen flags, by app bundle name.
    static let emulatorFullScreenArguments: [String: [String]] = [
        "RetroArch.app": ["-f"],
        "Dolphin.app": ["-C", "Dolphin.Display.Fullscreen=True"],
        "PCSX2.app": ["-fullscreen"],
        "melonDS.app": ["-f"],
        "PPSSPP.app": ["--fullscreen"],
    ]

    /// Environment variables for a launch of an app whose `Info.plist` is `infoPlist`.
    static func environment(style: LaunchStyle, infoPlist: [String: Any]?) -> [String: String] {
        guard style != .standard, declaresFullScreenSwitch(infoPlist) else { return [:] }
        return [nxnativeFullScreenKey: style == .fullScreen ? "1" : "0"]
    }

    /// The target with full-screen flags added for a known emulator (full screen only; windowed is their default).
    static func target(_ target: LaunchTarget, style: LaunchStyle) -> LaunchTarget {
        guard style == .fullScreen, case let .applicationWithArguments(path, arguments) = target,
              let flags = emulatorFullScreenArguments[(path as NSString).lastPathComponent]
        else { return target }
        return .applicationWithArguments(path: path, arguments: flags + arguments)
    }

    /// Whether an nxnative build declares `DM_FULLSCREEN`.
    static func declaresFullScreenSwitch(_ infoPlist: [String: Any]?) -> Bool {
        guard let settings = infoPlist?[settingsKey] as? [[String: Any]] else { return false }
        return settings.contains { $0[settingEnvironmentKey] as? String == nxnativeFullScreenKey }
    }
}
