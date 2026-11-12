import Foundation
@testable import nativehaul
import Testing

/// ADR 0052: TV mode asks nxnative builds for full screen through their declared DM_FULLSCREEN switch and emulators
/// through their documented flags; desktop launches change nothing.
@MainActor
struct FullScreenLaunchTests {
    private let nxnativeInfo: [String: Any] = ["DMSettings": [["env": "DM_OPMODE"], ["env": "DM_FULLSCREEN"]]]

    @Test func nxnativeBuildsGetTheirFullScreenSwitch() {
        #expect(FullScreenLaunch.environment(style: .fullScreen, infoPlist: nxnativeInfo) == ["DM_FULLSCREEN": "1"])
        #expect(FullScreenLaunch.environment(style: .windowed, infoPlist: nxnativeInfo) == ["DM_FULLSCREEN": "0"])
    }

    @Test func desktopLaunchesAndUnknownAppsAreUntouched() {
        #expect(FullScreenLaunch.environment(style: .standard, infoPlist: nxnativeInfo).isEmpty)
        #expect(FullScreenLaunch.environment(style: .fullScreen, infoPlist: ["CFBundleName": "Other"]).isEmpty)
        let plain = LaunchTarget.application(path: "/Games/Tideborn.app")
        #expect(FullScreenLaunch.target(plain, style: .fullScreen) == plain)
        let emulator = LaunchTarget.applicationWithArguments(path: "/Applications/RetroArch.app", arguments: ["rom"])
        #expect(FullScreenLaunch.target(emulator, style: .standard) == emulator)
    }

    @Test func emulatorsGetTheirFullScreenFlagFirst() {
        let target = LaunchTarget.applicationWithArguments(
            path: "/Applications/RetroArch.app", arguments: ["-L", "core.dylib", "game.gba"]
        )
        #expect(FullScreenLaunch.target(target, style: .fullScreen) == .applicationWithArguments(
            path: "/Applications/RetroArch.app", arguments: ["-f", "-L", "core.dylib", "game.gba"]
        ))
        #expect(FullScreenLaunch.target(target, style: .windowed) == target)
    }

    @Test func desktopOpenConfigurationIsUnchanged() {
        let configuration = WorkspaceGameLauncher.openConfiguration(arguments: nil)
        #expect(configuration.environment.isEmpty)
        let tv = WorkspaceGameLauncher.openConfiguration(arguments: nil, environment: ["DM_FULLSCREEN": "1"])
        #expect(tv.environment == ["DM_FULLSCREEN": "1"])
    }
}
