import Foundation
@testable import Playrite
import SwiftData
import Testing

/// ADR 0029: the app is called Retriever, while every identifier the user's data depends on stays frozen at its
/// Playrite value.
struct AppInfoTests {
    @Test func productNameIsRetriever() {
        #expect(AppInfo.productName == "Retriever")
    }

    @Test func dataIdentifiersStayFrozen() {
        #expect(AppInfo.bundleIdentifier == "com.studiojrba.Playrite")
        #expect(AppInfo.keychainService == "com.studiojrba.Playrite")
        #expect(AppInfo.supportFolderName == "Playrite")
        #expect(AppInfo.storeFileName == "default.store")
    }

    @Test func hostBundleKeepsTheFrozenIdentifierUnderTheNewName() {
        #expect(Bundle.main.bundleIdentifier == AppInfo.bundleIdentifier)
        #expect(Bundle.main.bundleURL.lastPathComponent == "Retriever.app")
        #expect(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String == "Retriever")
        #expect(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String == "Retriever")
    }

    @Test func applicationSupportPathsStayInThePlayriteFolder() {
        let folder = "/Application Support/\(AppInfo.supportFolderName)/"
        #expect(FileArtworkCache.defaultRoot().path.contains(folder))
        #expect(FileHLTBCache.defaultURL().path.contains(folder))
        #expect(FileAuditLog.defaultPath().contains(folder))
        #expect(ScriptBackupService.defaultDirectory().contains(folder))
    }

    @Test func swiftDataStoreLocationIsIndependentOfTheAppName() {
        let schema = Schema(PlayriteSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        #expect(configuration.url == URL.applicationSupportDirectory.appending(path: AppInfo.storeFileName))
    }
}
