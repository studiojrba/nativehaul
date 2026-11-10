import SwiftUI
import UniformTypeIdentifiers

/// File wrapper used by `fileExporter` to save a library archive.
struct LibraryJSONDocument: FileDocument {
    /// Supported content types.
    static let readableContentTypes: [UTType] = [.json]

    /// Encoded archive.
    let data: Data

    /// Wraps already-encoded data.
    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
