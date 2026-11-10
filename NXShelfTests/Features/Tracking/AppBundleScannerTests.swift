import Foundation
@testable import NXShelf
import Testing

struct AppBundleScannerTests {
    private let fileManager = FileManager.default

    private func makeRoot() -> URL {
        fileManager.temporaryDirectory.appendingPathComponent("NXShelfScan-\(UUID().uuidString)")
    }

    private func makeDirectory(_ root: URL, _ relative: String) throws {
        try fileManager.createDirectory(at: root.appendingPathComponent(relative), withIntermediateDirectories: true)
    }

    @Test func findsTopLevelAndNestedApps() throws {
        let root = makeRoot()
        try makeDirectory(root, "Beta.app")
        try makeDirectory(root, "Sub/Alpha.app")
        try makeDirectory(root, "NotAnApp")
        defer { try? fileManager.removeItem(at: root) }

        let apps = try AppBundleScanner().scan(folder: root.path)
        #expect(apps.map(\.name) == ["Alpha", "Beta"])
    }

    @Test func missingFolderReturnsEmpty() throws {
        #expect(try AppBundleScanner().scan(folder: "/nonexistent/\(UUID().uuidString)").isEmpty)
    }

    @Test func respectsMaxDepth() throws {
        let root = makeRoot()
        try makeDirectory(root, "a/b/c/Four.app")
        try makeDirectory(root, "a/b/c/d/Five.app")
        defer { try? fileManager.removeItem(at: root) }

        let deep = try AppBundleScanner().scan(folder: root.path, options: AppBundleScanOptions(maxDepth: 4))
        #expect(deep.map(\.name) == ["Four"])
        let shallow = try AppBundleScanner().scan(folder: root.path)
        #expect(shallow.isEmpty)
    }

    @Test func neverDescendsIntoBundles() throws {
        let root = makeRoot()
        try makeDirectory(root, "Outer.app/Contents/Resources/Inner.app")
        defer { try? fileManager.removeItem(at: root) }

        let apps = try AppBundleScanner().scan(folder: root.path, options: AppBundleScanOptions(maxDepth: 4))
        #expect(apps.map(\.name) == ["Outer"])
    }

    @Test func skipsTrashHiddenAndItself() throws {
        let root = makeRoot()
        try makeDirectory(root, ".Trash/Gone.app")
        try makeDirectory(root, "NX Shelf.app")
        try makeDirectory(root, "Excluded/Own.app")
        try makeDirectory(root, "Kept.app")
        defer { try? fileManager.removeItem(at: root) }

        let options = AppBundleScanOptions(
            maxDepth: 4,
            excludedBundlePaths: [root.appendingPathComponent("Excluded/Own.app").path]
        )
        let apps = try AppBundleScanner().scan(folder: root.path, options: options)
        #expect(apps.map(\.name) == ["Kept"])
        #expect(AppBundleScanner.isInTrash("/Users/demo/.Trash/Game.app"))
        #expect(try AppBundleScanner().scan(folder: root.appendingPathComponent(".Trash").path).isEmpty)
    }

    @Test func readsTitleFromInfoPlistAndDetectsPortLibrary() throws {
        let root = makeRoot()
        try makeDirectory(root, "tideborn_port.app/Contents")
        try makeDirectory(root, ".nx2apple-library")
        let plist: [String: Any] = ["CFBundleName": "Tideborn Short", "CFBundleDisplayName": "Tideborn"]
        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: root.appendingPathComponent("tideborn_port.app/Contents/Info.plist"))
        try makeDirectory(root, "Other/Plain.app")
        defer { try? fileManager.removeItem(at: root) }

        let apps = try AppBundleScanner().scan(folder: root.path, options: .folderImport)
        let port = try #require(apps.first { $0.name == "tideborn_port" })
        #expect(port.title == "Tideborn")
        #expect(port.hasPortLibrarySibling)
        let plain = try #require(apps.first { $0.name == "Plain" })
        #expect(plain.title == "Plain")
        #expect(!plain.hasPortLibrarySibling)
    }
}
