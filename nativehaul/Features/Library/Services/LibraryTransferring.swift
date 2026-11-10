import Foundation

/// Exports and imports the library as JSON. Live: ``LibraryTransferService``; mock: ``MockLibraryTransferService``.
@MainActor
protocol LibraryTransferring: AnyObject {
    /// Serialises the whole library to JSON.
    func exportData() throws -> Data
    /// Imports a JSON archive, skipping items that already exist, and saves.
    func importData(_ data: Data) throws -> ImportSummary
}
