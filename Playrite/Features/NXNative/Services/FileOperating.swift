import Foundation

/// File-system operations available to the NXNative module.
///
/// By design there is **no delete and no empty-Trash operation**: destructive cleanup can only move items to
/// the Trash, where the user can recover them. Live: ``LocalFileOperations``; mock: ``InMemoryFileOperations``.
protocol FileOperating: Sendable {
    /// Whether anything exists at `path`.
    func fileExists(atPath path: String) -> Bool
    /// Whether `path` is a directory.
    func isDirectory(atPath path: String) -> Bool
    /// Whether `path` is an executable regular file.
    func isExecutableFile(atPath path: String) -> Bool
    /// Names (not paths) of the immediate children of a directory, including hidden ones.
    func contentsOfDirectory(atPath path: String) throws -> [String]
    /// Size of a regular file in bytes.
    func fileSize(atPath path: String) throws -> Int64
    /// Reads a whole file.
    func readData(atPath path: String) throws -> Data
    /// Reads at most `length` bytes starting at `offset` (fewer at the end of the file). For headers of large files.
    func readData(atPath path: String, offset: Int, length: Int) throws -> Data
    /// Overwrites a file **in place** (keeping its permissions) or creates it.
    func writeData(_ data: Data, toPath path: String) throws
    /// Copies an item (preserving permissions).
    func copyItem(atPath source: String, toPath destination: String) throws
    /// Moves or renames an item. Fails if the destination exists.
    func moveItem(atPath source: String, toPath destination: String) throws
    /// Creates a directory and any missing parents.
    func createDirectory(atPath path: String) throws
    /// Moves an item to the user's Trash. Never empties the Trash.
    func trashItem(atPath path: String) throws
}
