import AppKit
import Foundation
@testable import nativehaul
import Testing

/// ADR 0030: Play hands the game the focus and nativehaul never takes it back (QA Finding #6: a built game only draws
/// while it is in front and focused).
@MainActor
struct LaunchFocusTests {
    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("nativehaul")
    }

    @Test func gamesAreOpenedInFrontWithTheFocus() {
        let plain = WorkspaceGameLauncher.openConfiguration(arguments: nil)
        #expect(plain.activates)
        #expect(!plain.createsNewApplicationInstance)
        let withArguments = WorkspaceGameLauncher.openConfiguration(arguments: ["-silent"])
        #expect(withArguments.activates)
        #expect(withArguments.arguments == ["-silent"])
        #expect(withArguments.createsNewApplicationInstance)
    }

    @Test func nativehaulNeverTakesTheFocusItself() throws {
        let forbidden = [
            "NSApp.activate", "NSApplication.shared.activate", "NSRunningApplication.current.activate",
            "activate(ignoringOtherApps", "makeKeyAndOrderFront", "orderFrontRegardless", "requestUserAttention",
            "openWindow", "NSAlert(",
        ]
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            for token in forbidden where text.contains(token) {
                offenders.append("\(url.lastPathComponent): \(token)")
            }
        }
        #expect(offenders.isEmpty, "Focus-taking APIs: \(offenders)")
    }

    @Test func playOnlyReportsInlineAndOpensNothing() async {
        let game = Game(title: "Ported Game")
        game.platform = .switchPort
        game.appBundlePath = "/Games/Ported Game.app"
        let launcher = RecordingGameLauncher()
        let viewModel = GameLaunchViewModel(
            game: game,
            launcher: launcher,
            watcher: MockPlaytimeWatcher(),
            fileExists: { _ in true }
        )
        await viewModel.launch()
        #expect(launcher.launched.count == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.fileRequest == nil)
        #expect(viewModel.lastLaunched != nil)
    }
}
