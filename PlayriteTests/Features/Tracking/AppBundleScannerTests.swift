import Foundation
@testable import Playrite
import Testing

struct AppBundleScannerTests {
    @Test func findsTopLevelAndNestedApps() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("PlayriteScan-\(UUID().uuidString)")
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: root.appendingPathComponent("Beta.app"), withIntermediateDirectories: true)
        try fileManager.createDirectory(
            at: root.appendingPathComponent("Sub/Alpha.app"),
            withIntermediateDirectories: true
        )
        try fileManager.createDirectory(at: root.appendingPathComponent("NotAnApp"), withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: root) }

        let apps = try AppBundleScanner().scan(folder: root.path)
        #expect(apps.map(\.name) == ["Alpha", "Beta"])
    }

    @Test func missingFolderReturnsEmpty() throws {
        #expect(try AppBundleScanner().scan(folder: "/nonexistent/\(UUID().uuidString)").isEmpty)
    }
}
