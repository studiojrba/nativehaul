import Foundation

/// Mock ``LibraryTransferring`` returning canned values.
@MainActor
final class MockLibraryTransferService: LibraryTransferring {
    /// Data returned by ``exportData()``.
    var exportResult = Data("{}".utf8)
    /// Summary returned by ``importData(_:)``.
    var importResult = ImportSummary()
    /// Payloads received by ``importData(_:)``.
    private(set) var importedPayloads: [Data] = []

    /// Creates the mock.
    init() {}

    func exportData() throws -> Data {
        exportResult
    }

    func importData(_ data: Data) throws -> ImportSummary {
        importedPayloads.append(data)
        return importResult
    }
}
