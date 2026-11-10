import Foundation
@testable import nativehaul
import Testing

/// ADR 0036: the Installed filter keeps installed games, flags unknown ones apart, and drops gone installs.
@MainActor
struct InstalledFilterTests {
    private static func presentApp() throws -> String {
        let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("InstalledFilterTests/Here.app")
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        return path
    }

    @Test func splitKeepsOrderAndCountsEachState() {
        let games = ["A", "B", "C", "D"].map { Game(title: $0) }
        let states: [String: InstallState] = ["A": .installed, "B": .unknown, "C": .notInstalled, "D": .installed]
        let split = InstalledSplit.make(games) { states[$0.title] ?? .unknown }
        #expect(split.installed.map(\.title) == ["A", "D"])
        #expect(split.unknown.map(\.title) == ["B"])
        #expect(split.notInstalledCount == 1)
        #expect(split.summary == "2 installed · 1 can't tell · 1 not installed")
    }

    @Test func summaryLeavesOutEmptyParts() {
        let split = InstalledSplit.make([Game(title: "A")]) { _ in .installed }
        #expect(split.summary == "1 installed")
    }

    @Test func theViewModelFiltersTheCurrentViewAndKeepsUnknownApart() throws {
        let repository = try MockLibraryRepository()
        let app = try Self.presentApp()
        let installed = Game(title: "Installed Port", platform: .switchPort, status: .playing)
        installed.appBundlePath = app
        let rom = Game(title: "ROM Copy", platform: .emulated)
        rom.romPath = app
        let gone = Game(title: "Gone", platform: .macNative)
        gone.appBundlePath = "/nowhere/Gone.app"
        let unknown = Game(title: "Unknown", platform: .emulated, status: .playing)
        for game in [installed, rom, gone, unknown] {
            repository.insert(game)
        }
        try repository.save()
        let viewModel = LibraryViewModel(repository: repository, transfer: MockLibraryTransferService())
        viewModel.reload()

        viewModel.filter.installedOnly = true
        #expect(viewModel.visibleGames.map(\.title) == ["Installed Port", "ROM Copy"])
        #expect(viewModel.installedSplit.unknown.map(\.title) == ["Unknown"])
        #expect(viewModel.installedSplit.notInstalledCount == 1)
        #expect(viewModel.jumpBackIn().map(\.title) == ["Installed Port"])

        viewModel.filter.section = .playing
        #expect(viewModel.visibleGames.map(\.title) == ["Installed Port"])
        #expect(viewModel.installedSplit.unknown.map(\.title) == ["Unknown"])

        viewModel.filter.installedOnly = false
        #expect(viewModel.visibleGames.map(\.title) == ["Installed Port", "Unknown"])
    }
}
