import Foundation

/// Mock ``FilePanelPresenting`` for previews and tests: answers with preset picks and counts the asks.
@MainActor
final class MockFilePanel: FilePanelPresenting {
    /// What the folder panel answers (`nil` is a cancel).
    var folder: URL?
    /// What the file panel answers (`nil` is a cancel).
    var file: URL?
    /// Folder panels shown.
    private(set) var folderAsks = 0
    /// File panels shown.
    private(set) var fileAsks = 0

    /// Creates the mock.
    init(folder: URL? = nil, file: URL? = nil) {
        self.folder = folder
        self.file = file
    }

    func chooseFolder() async -> URL? {
        folderAsks += 1
        return folder
    }

    func chooseFile(allowedExtensions _: [String]) async -> URL? {
        fileAsks += 1
        return file
    }
}
