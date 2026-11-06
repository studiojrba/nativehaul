import Foundation

/// Lists the staging folder (names and sizes only — title contents are never read).
struct StagedFileInventory: Sendable {
    private let files: any FileOperating

    /// Creates the inventory.
    init(files: any FileOperating) {
        self.files = files
    }

    /// Non-hidden regular files in `directory`, sorted by name.
    func inventory(of directory: String) -> [StagedFile] {
        let names = (try? files.contentsOfDirectory(atPath: directory)) ?? []
        return names
            .filter { !$0.hasPrefix(".") }
            .map { (directory as NSString).appendingPathComponent($0) }
            .filter { !files.isDirectory(atPath: $0) }
            .map { path in
                StagedFile(
                    path: path,
                    size: (try? files.fileSize(atPath: path)) ?? 0,
                    kind: StagedFileKind(pathExtension: (path as NSString).pathExtension)
                )
            }
    }
}
