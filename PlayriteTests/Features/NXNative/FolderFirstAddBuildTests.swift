import Foundation
@testable import Playrite
import Testing

/// J.R's requirement (ADR 0023): point Add Build at one folder with a random mix and it sorts base, update and DLC by
/// title ID — one job per game, never mixing games, and plain reasons when a folder can't be built.
@MainActor
struct FolderFirstAddBuildTests {
    private typealias Folder = FolderFirstFixtures

    private func scan(_ path: String, _ files: InMemoryFileOperations) -> GameFolderScan {
        GameFolderScanner(files: files).scan(path)
    }

    @Test(arguments: [
        ("01008FE00E2F6000", SwitchTitleID.Kind.base, "01008FE00E2F6000"),
        ("01008FE00E2F6800", .update, "01008FE00E2F6000"),
        ("01008FE00E2F7001", .dlc, "01008FE00E2F6000"),
        ("01008FE00E2F702C", .dlc, "01008FE00E2F6000"),
        ("01007EF00011E000", .base, "01007EF00011E000"),
        ("01007EF00011F001", .dlc, "01007EF00011E000"),
    ])
    func titleIDsRelateToTheirBaseGame(id: String, kind: SwitchTitleID.Kind, base: String) throws {
        let titleID = try #require(SwitchTitleID(id))
        #expect(titleID.kind == kind)
        #expect(titleID.baseID.hex == base)
    }

    @Test func mixedFolderIsSortedIntoOneGame() {
        guard case let .games(games, notes) = scan(Folder.oppw, Folder.mixedFolder()) else {
            Issue.record("Expected games")
            return
        }
        #expect(games == [DetectedGame(
            sourcePath: Folder.oppw,
            name: "One Piece Pirate Warriors 4",
            titleID: Folder.oppwBase,
            details: "Base game · update v1179648 · 3 DLC",
            isSwitch2: false
        )])
        #expect(notes.isEmpty)
    }

    @Test func dlcIsCountedWithoutAnUpdate() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/T/Tideborn [0100ABCD00010000][v0].nsp")
        files.addFile("/dl/T/Tideborn [DLC One] [0100ABCD00011001][v0].nsp")
        files.addFile("/dl/T/Tideborn [DLC Two] [0100ABCD00011002][v0].nsp")
        guard case let .games(games, _) = scan("/dl/T", files) else {
            Issue.record("Expected games")
            return
        }
        #expect(games.map(\.details) == ["Base game · 2 DLC"])
    }

    @Test func oneFolderWithTwoGamesListsBothAndQueuesOnlyWhatIsPicked() throws {
        let files = InMemoryFileOperations()
        files.addFile("/dl/Mix/Tideborn [0100ABCD00010000][v0].nsp")
        files.addFile("/dl/Mix/Tideborn [0100ABCD00010800][v65536].nsp")
        files.addFile("/dl/Mix/Ridgeback [0100F00D00020000][v0].xci")
        files.addFile("/dl/Mix/Ridgeback [DLC Pack] [0100F00D00021001][v0].nsp")
        let model = AddBuildViewModel(files: files)
        model.choose("/dl/Mix")
        #expect(model.games.map(\.name) == ["Tideborn", "Ridgeback"])
        #expect(model.games.map(\.details) == ["Base game · update v65536", "Base game · 1 DLC"])
        #expect(model.isChoosingAmongGames)
        #expect(!model.canQueue)
        try model.toggle(#require(model.games.last))
        let picked = model.jobsToQueue()
        #expect(picked.map(\.title.titleID) == ["0100F00D00020000"])
        #expect(picked.map(\.sourcePath) == ["/dl/Mix"])
        model.selectAll()
        #expect(model.jobsToQueue().map(\.title.name) == ["Tideborn", "Ridgeback"])
        #expect(model.jobsToQueue().allSatisfy { $0.title.architecture == .bit64 })
    }

    @Test func aSharedFolderTellsTheEngineWhichGame() {
        let files = NXPlayFixtures.jrFiles()
        files.addFile("/dl/Mix/Tideborn [0100ABCD00010000][v0].nsp")
        files.addFile("/dl/Mix/Ridgeback [0100F00D00020000][v0].nsp")
        let title = TitleInfo(titleID: "0100F00D00020000", name: "Ridgeback", architecture: .bit64)
        let invocation = EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: "/dl/Mix", title: title),
            configuration: NXPlayFixtures.resolved(files),
            workDirectory: NXPlayFixtures.work,
            files: files,
            homeDirectory: NXPlayFixtures.home
        )
        #expect(invocation.arguments.suffix(6) == [
            "--title-id", "0100F00D00020000", "--platform", "mac-app", "-o", "\(NXPlayFixtures.work)/Ridgeback.app",
        ])
        let single = EngineInvocationBuilder.invocation(
            for: BuildJob(sourcePath: Folder.oppw, title: title),
            configuration: NXPlayFixtures.resolved(Folder.mixedFolder()),
            workDirectory: NXPlayFixtures.work,
            files: Folder.mixedFolder(),
            homeDirectory: NXPlayFixtures.home
        )
        #expect(!single.arguments.contains("--title-id"))
    }

    @Test func anUpdateWithoutItsBaseFailsInTheSheetAndQueuesNothing() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/Pikmin 3 Deluxe/Pikmin 3 Deluxe [0100F4C009322800][v262144] (0.03 GB).nsp")
        let model = AddBuildViewModel(files: files)
        model.choose("/dl/Pikmin 3 Deluxe")
        #expect(model.failureReason
            == "This folder has an update for Pikmin 3 Deluxe (0100F4C009322000) but not its base game.")
        #expect(!model.canQueue)
        #expect(model.jobsToQueue().isEmpty)
    }

    @Test func orphansBesideARealGameAreSkippedWithANote() {
        let files = Folder.mixedFolder()
        files.addFile("\(Folder.oppw)/Pikmin 3 Deluxe [DLC A] [0100F4C009323001][v0].nsp")
        files.addFile("\(Folder.oppw)/Pikmin 3 Deluxe [DLC B] [0100F4C009323002][v0].nsp")
        guard case let .games(games, notes) = scan(Folder.oppw, files) else {
            Issue.record("Expected games")
            return
        }
        #expect(games.count == 1)
        #expect(notes ==
            ["Skipped: This folder has 2 DLC for Pikmin 3 Deluxe (0100F4C009322000) but not its base game."])
    }

    @Test func aFolderWithoutGameFilesSaysSo() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/Empty/readme.txt")
        #expect(scan("/dl/Empty", files) == .failure(GameFolderScan.noGameFilesReason))
        #expect(GameFolderScan.noGameFilesReason.hasPrefix("No game files found in this folder."))
    }

    @Test func aLoneUpdateFileIsRefusedWithAPlainReason() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/Pikmin 3 Deluxe [0100F4C009322800][v262144].nsp")
        #expect(scan("/dl/Pikmin 3 Deluxe [0100F4C009322800][v262144].nsp", files) == .failure(
            "This file is an update for Pikmin 3 Deluxe (0100F4C009322000), not its base game. Choose the base "
                + "game's file, or the folder holding both."
        ))
    }

    @Test func switch2DumpFolderGetsAnAtAGlanceSummary() {
        let files = InMemoryFileOperations()
        let folder = "/dl/Ridgeback [0400A3A01EE4C000]"
        NXPlayFixtures.addSwitch2Dump(files, at: folder)
        files.addDirectory("\(folder)/updates/65536/romfs")
        files.addDirectory("\(folder)/updates/131072/romfs")
        files.addDirectory("\(folder)/dlc/0400A3A01EE4D001")
        files.addDirectory("\(folder)/dlc/0400A3A01EE4D002")
        #expect(scan(folder, files) == .games([DetectedGame(
            sourcePath: folder,
            name: "Ridgeback",
            titleID: "0400A3A01EE4C000",
            details: "Switch 2 · base game · 2 updates (newest v131072) · 2 DLC",
            isSwitch2: true
        )], notes: []))
    }

    @Test func aFolderOfSeveralNupsListsEachAsItsOwnGame() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/S2/Ridgeback [0400A3A01EE4C000][v0].nup")
        files.addFile("/dl/S2/Tideborn [0400ABCD00010000][v65536].nup")
        let model = AddBuildViewModel(files: files)
        model.choose("/dl/S2")
        #expect(model.games.map(\.sourcePath) == [
            "/dl/S2/Ridgeback [0400A3A01EE4C000][v0].nup",
            "/dl/S2/Tideborn [0400ABCD00010000][v65536].nup",
        ])
        #expect(model.isChoosingAmongGames)
    }

    @Test func theLoneOcarinaNupStillQueuesInOneClick() {
        let files = InMemoryFileOperations()
        let nup = "/Users/jr/Downloads/The Legend of Zelda Ocarina of Time [0400486024DEC000][v131072].nup"
        files.addFile(nup)
        let model = AddBuildViewModel(files: files)
        model.choose(nup)
        #expect(model.games.first?.details == "Switch 2 · .nup · v131072")
        #expect(model.canQueue)
        let job = model.jobsToQueue()
        #expect(job.map(\.sourcePath) == [nup])
        #expect(job.map(\.title.name) == ["The Legend of Zelda Ocarina of Time"])
        #expect(job.map(\.title.titleID) == ["0400486024DEC000"])
    }

    @Test func aSingleGameIsSelectedAndNamedStraightAway() {
        let model = AddBuildViewModel(files: Folder.mixedFolder())
        model.choose(Folder.oppw)
        #expect(model.canQueue)
        #expect(model.name == "One Piece Pirate Warriors 4")
        model.name = "  "
        #expect(!model.canQueue)
    }

    @Test func packagesWithoutNameTagsAreIdentifiedFromTheirHeader() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/H/base.nsp", contents: Folder.pfs0([
            ("01008fe00e2f6000000000000000000b.tik", Data(repeating: 0, count: 8)),
            ("a.nca", Data()),
        ]))
        let xml = "<ContentMeta><Type>Patch</Type><Id>0x01008fe00e2f6800</Id><Version>1179648</Version></ContentMeta>"
        files.addFile("/dl/H/update.nsp", contents: Folder.pfs0([
            ("b.nca", Data(repeating: 0, count: 16)),
            ("c.cnmt.xml", Data(xml.utf8)),
        ]))
        guard case let .games(games, _) = scan("/dl/H", files) else {
            Issue.record("Expected games")
            return
        }
        #expect(games.map(\.titleID) == [Folder.oppwBase])
        #expect(games.map(\.details) == ["Base game · update v1179648"])
    }

    @Test func malformedHeadersAreLeftToTheEngine() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/X/game.xci", contents: Data("PFS0\u{FF}\u{FF}\u{FF}\u{7F}".utf8))
        guard case let .games(games, _) = scan("/dl/X", files) else {
            Issue.record("Expected games")
            return
        }
        #expect(games.map(\.details) == ["1 game file (sorted by the engine)"])
        #expect(games.map(\.titleID) == [""])
    }
}

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
}
