import Foundation
@testable import NXShelf
import Synchronization

/// A ``SecretStore`` that records whether each read happened on the main thread (crash pass, ADR 0044).
final class ThreadRecordingSecretStore: SecretStore {
    private let values: Mutex<[SecretKey: String]>
    private let reads = Mutex<[Bool]>([])

    /// Creates the store with `values`.
    init(_ values: [SecretKey: String] = [:]) {
        self.values = Mutex(values)
    }

    /// Number of reads made on the main thread.
    var mainThreadReads: Int {
        reads.withLock { $0.filter(\.self).count }
    }

    /// Number of reads made off the main thread.
    var backgroundReads: Int {
        reads.withLock { $0.filter { !$0 }.count }
    }

    func secret(for key: SecretKey) throws -> String? {
        reads.withLock { $0.append(Thread.isMainThread) }
        return values.withLock { $0[key] }
    }

    func setSecret(_ value: String, for key: SecretKey) throws {
        values.withLock { $0[key] = value }
    }

    func removeSecret(for key: SecretKey) throws {
        _ = values.withLock { $0.removeValue(forKey: key) }
    }
}
