import Foundation
import SwiftData

/// Builds SwiftData containers for the app, previews and tests.
enum ModelContainerFactory {
    /// Creates a container. In-memory containers are used by previews and tests; the on-disk store lives at
    /// ``AppInfo/storeURL`` (ADR 0045), never SwiftData's shared default location.
    static func make(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(NXShelfSchema.models)
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            try FileManager.default.createDirectory(at: AppInfo.supportDirectory, withIntermediateDirectories: true)
            configuration = ModelConfiguration(schema: schema, url: AppInfo.storeURL)
        }
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
