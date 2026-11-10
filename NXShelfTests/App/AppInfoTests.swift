import Foundation
@testable import NXShelf
import SwiftData
import Testing

/// ADR 0045: NX Shelf owns a brand-new identity, as if it had always been NX Shelf. Nothing points at, reads or
/// migrates data stored under an earlier name.
struct AppInfoTests {
    private static let sourceRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "NXShelf")

    @Test func theIdentityIsNXShelfThroughout() {
        #expect(AppInfo.productName == "NX Shelf")
        #expect(AppInfo.bundleIdentifier == "com.studiojrba.NXShelf")
        #expect(AppInfo.keychainService == "com.studiojrba.NXShelf")
        #expect(AppInfo.supportFolderName == "NX Shelf")
        #expect(AppInfo.storeFileName == "NXShelf.store")
    }

    @Test func theHostBundleCarriesTheIdentity() {
        #expect(Bundle.main.bundleIdentifier == AppInfo.bundleIdentifier)
        #expect(Bundle.main.bundleURL.lastPathComponent == "NX Shelf.app")
        #expect(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "NX Shelf")
    }

    @Test func everythingOnDiskLivesInTheNXShelfFolder() {
        let folder = "/Application Support/NX Shelf/"
        #expect(AppInfo.storeURL.path(percentEncoded: false).hasSuffix("/Application Support/NX Shelf/NXShelf.store"))
        #expect(FileArtworkCache.defaultRoot().path(percentEncoded: false).contains(folder))
        #expect(FileHLTBCache.defaultURL().path(percentEncoded: false).contains(folder))
        #expect(FileAuditLog.defaultPath().contains(folder))
        #expect(ScriptBackupService.defaultDirectory().contains(folder))
        #expect(TitleDBStore.defaultCacheFile().path(percentEncoded: false).contains(folder))
    }

    @Test func noSourceReachesForAnEarlierIdentity() throws {
        let markers = ["com.studiojrba.Playrite", "Application Support/Playrite", "\"default.store\"", "Retriever"]
        let enumerator = FileManager.default.enumerator(at: Self.sourceRoot, includingPropertiesForKeys: nil)
        var offenders: [String] = []
        while let url = enumerator?.nextObject() as? URL {
            guard ["swift", "json"].contains(url.pathExtension) else { continue }
            let text = try String(contentsOf: url, encoding: .utf8)
            if markers.contains(where: text.contains) {
                offenders.append(url.lastPathComponent)
            }
        }
        #expect(offenders.isEmpty, "Earlier identity referenced in: \(offenders)")
    }
}
