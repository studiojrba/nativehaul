import Foundation
@testable import nativehaul
import SwiftData
import Testing

/// ADR 0045: nativehaul owns a brand-new identity, as if it had always been nativehaul. Nothing points at, reads or
/// migrates data stored under an earlier name.
struct AppInfoTests {
    private static let sourceRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .appending(path: "nativehaul")

    @Test func theIdentityIsNativehaulThroughout() {
        #expect(AppInfo.productName == "nativehaul")
        #expect(AppInfo.bundleIdentifier == "com.studiojrba.nativehaul")
        #expect(AppInfo.keychainService == "com.studiojrba.nativehaul")
        #expect(AppInfo.supportFolderName == "nativehaul")
        #expect(AppInfo.storeFileName == "nativehaul.store")
    }

    @Test func theHostBundleCarriesTheIdentity() {
        #expect(Bundle.main.bundleIdentifier == AppInfo.bundleIdentifier)
        #expect(Bundle.main.bundleURL.lastPathComponent == "nativehaul.app")
        #expect(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "nativehaul")
    }

    @Test func everythingOnDiskLivesInTheNativehaulFolder() {
        let folder = "/Application Support/nativehaul/"
        #expect(AppInfo.storeURL.path(percentEncoded: false)
            .hasSuffix("/Application Support/nativehaul/nativehaul.store"))
        #expect(FileArtworkCache.defaultRoot().path(percentEncoded: false).contains(folder))
        #expect(FileHLTBCache.defaultURL().path(percentEncoded: false).contains(folder))
        #expect(FileAuditLog.defaultPath().contains(folder))
        #expect(ScriptBackupService.defaultDirectory().contains(folder))
        #expect(TitleDBStore.defaultCacheFile().path(percentEncoded: false).contains(folder))
    }

    @Test func noSourceReachesForAnEarlierIdentity() throws {
        let markers = [
            "com.studiojrba.Playrite", "Application Support/Playrite", "\"default.store\"", "Retriever",
            "com.studiojrba.NXShelf", "Application Support/NX Shelf", "NXShelf.store", "NX Shelf",
        ]
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
