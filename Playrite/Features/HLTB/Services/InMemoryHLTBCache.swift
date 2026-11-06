import Foundation
import Synchronization

/// Mock ``HLTBCaching``.
final class InMemoryHLTBCache: HLTBCaching {
    private let storage: Mutex<[UUID: HLTBEstimate]>

    /// Creates the cache with initial contents.
    init(_ initial: [UUID: HLTBEstimate] = [:]) {
        storage = Mutex(initial)
    }

    func load() throws -> [UUID: HLTBEstimate] {
        storage.withLock { $0 }
    }

    func save(_ estimates: [UUID: HLTBEstimate]) throws {
        storage.withLock { $0 = estimates }
    }
}
