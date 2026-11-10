import Foundation
@testable import NXShelf
import Testing

/// Guards the module's hard rules: no deletion / Trash-emptying code, and nothing bundled.
struct SafetyPolicyTests {
    private var sourceRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("NXShelf")
    }

    @Test func noDeletionOrTrashEmptyingAPIsInSource() throws {
        let forbidden = ["removeItem(", "emptyTrash", "rm -rf", "unlink(", "Finder\" to empty"]
        let enumerator = FileManager.default.enumerator(at: sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            for token in forbidden where text.contains(token) {
                offenders.append("\(url.lastPathComponent): \(token)")
            }
        }
        #expect(offenders.isEmpty, "Forbidden destructive APIs: \(offenders)")
    }

    @Test func appBundleContainsNoEngineKeysOrGames() {
        let forbiddenExtensions: Set = ["keys", "nsp", "xci", "nca", "nsz", "xcz"]
        let enumerator = FileManager.default.enumerator(atPath: Bundle.main.bundlePath)
        var offenders: [String] = []
        while let path = enumerator?.nextObject() as? String {
            let name = (path as NSString).lastPathComponent.lowercased()
            if name.contains("nxnative") || forbiddenExtensions.contains((name as NSString).pathExtension) {
                offenders.append(path)
            }
        }
        #expect(offenders.isEmpty, "Bundled forbidden items: \(offenders)")
    }

    @Test func configurationNeverStoresSecrets() throws {
        let data = try JSONEncoder().encode(EngineConfiguration())
        let keys = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any]).keys
        #expect(!keys.contains { $0.lowercased().contains("key") && $0 != "hiddenLibraryFolderName" })
    }
}
