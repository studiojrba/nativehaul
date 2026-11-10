import Foundation
@testable import NXShelf
import Testing

struct CrossOverBottleScannerTests {
    private let fileManager = FileManager.default

    private func touch(_ root: URL, _ relative: String) throws {
        let url = root.appendingPathComponent(relative)
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data().write(to: url)
    }

    @Test func findsBottlesAndGameFoldersApplyingSkipList() throws {
        let root = fileManager.temporaryDirectory.appendingPathComponent("NXShelfBottles-\(UUID().uuidString)")
        defer { try? fileManager.removeItem(at: root) }
        try touch(root, "Games/drive_c/Program Files/Lanternfall/Lanternfall.exe")
        try touch(root, "Games/drive_c/Program Files/Lanternfall/unins000.exe")
        try touch(root, "Games/drive_c/Program Files (x86)/Ashen Road/bin/x64/AshenRoad.exe")
        try touch(root, "Games/drive_c/Program Files/Common Files/thing.exe")
        try touch(root, "Games/drive_c/Program Files/Only Tools/unins000.exe")
        try touch(root, "Games/drive_c/Program Files/Docs/readme.txt")
        try touch(root, "Empty/drive_c/Program Files/.keep")

        let result = CrossOverBottleScanner().scanBottles(at: root.path)
        #expect(result.bottles == ["Empty", "Games"])
        #expect(Set(result.installs.map(\.name)) == ["Lanternfall", "Ashen Road"])
        let lanternfall = try #require(result.installs.first { $0.name == "Lanternfall" })
        #expect(lanternfall.executablePath.hasSuffix("Lanternfall.exe"))
        #expect(lanternfall.librarySummary == "CrossOver bottle: Games")
    }

    @Test func missingRootIsEmpty() {
        #expect(CrossOverBottleScanner().scanBottles(at: "/nonexistent/\(UUID().uuidString)") == CrossOverScanResult())
    }
}
