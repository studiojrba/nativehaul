import Foundation
@testable import nativehaul
import Testing

/// J.R: new builds start where downloads land.
@MainActor
struct AddBuildPickerStartTests {
    @Test func bothAddBuildPickersOpenInDownloads() {
        #expect(EngineConfiguration.gameFolderRequest.startingFolder == "~/Downloads")
        #expect(EngineConfiguration.gameFileRequest.startingFolder == "~/Downloads")
    }

    @Test func otherPromptsKeepTheSystemDefault() {
        #expect(EngineConfiguration().keysRequest.startingFolder == nil)
    }

    /// J.R's scope: Downloads is only where the build-input picker opens. Where games live and where built apps go
    /// stay the user's own settings, with their existing defaults.
    @Test func theGameAndOutputSideNeverDefaultsToDownloads() {
        let configuration = EngineConfiguration()
        #expect(configuration.outputDirectory == TrackingPreferences.defaultGamesFolder)
        #expect(configuration.workRoot == "~/Switch/Work")
        #expect(configuration.stagingDirectory == "~/Switch/Staging")
        let gameSide = [configuration.outputDirectory, configuration.workRoot, configuration.stagingDirectory]
        #expect(!gameSide.contains { $0.localizedCaseInsensitiveContains("downloads") })
    }
}
