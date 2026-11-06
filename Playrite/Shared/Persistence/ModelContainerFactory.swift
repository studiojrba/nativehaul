import Foundation
import SwiftData

/// Builds SwiftData containers for the app, previews and tests.
enum ModelContainerFactory {
    /// Creates a container. In-memory containers are used by previews and tests.
    static func make(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(PlayriteSchema.models)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
