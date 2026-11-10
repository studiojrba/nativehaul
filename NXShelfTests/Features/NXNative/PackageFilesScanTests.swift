import Foundation
@testable import NXShelf
import Testing

/// ADR 0023: what the folder scan reads from package files themselves — header identities, malformed headers, and
/// downloads that haven't finished.
@MainActor
struct PackageFilesScanTests {
    private typealias Folder = FolderFirstFixtures

    private func scan(_ path: String, _ files: InMemoryFileOperations) -> GameFolderScan {
        GameFolderScanner(files: files).scan(path)
    }

    @Test func unfinishedDownloadsInAPickedFolderAreLeftOut() {
        let files = InMemoryFileOperations()
        files.addFile("/dl/T/Tideborn [0100ABCD00010000][v0].nsp")
        files.addFile("/dl/T/Tideborn [DLC One] [0100ABCD00011001][v0].nsp")
        files.addFile("/dl/T/Tideborn [DLC One] [0100ABCD00011001][v0].nsp.aria2")
        files.addFile("/dl/T/Tideborn [0100ABCD00010800][v65536].nsp.crdownload")
        guard case let .games(games, _) = scan("/dl/T", files) else {
            Issue.record("Expected games")
            return
        }
        #expect(games.map(\.details) == ["Base game"])
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
