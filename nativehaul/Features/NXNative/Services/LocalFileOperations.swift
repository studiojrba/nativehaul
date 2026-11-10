import Foundation

/// Live ``FileOperating`` backed by `FileManager`. Contains no deletion or Trash-emptying code.
struct LocalFileOperations: FileOperating {
    private var manager: FileManager {
        .default
    }

    func fileExists(atPath path: String) -> Bool {
        manager.fileExists(atPath: path)
    }

    func isDirectory(atPath path: String) -> Bool {
        var isDirectory: ObjCBool = false
        return manager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    func isExecutableFile(atPath path: String) -> Bool {
        !isDirectory(atPath: path) && manager.isExecutableFile(atPath: path)
    }

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        try manager.contentsOfDirectory(atPath: path).sorted()
    }

    func fileSize(atPath path: String) throws -> Int64 {
        let attributes = try manager.attributesOfItem(atPath: path)
        return (attributes[.size] as? NSNumber)?.int64Value ?? 0
    }

    func readData(atPath path: String) throws -> Data {
        try Data(contentsOf: URL(fileURLWithPath: path))
    }

    func readData(atPath path: String, offset: Int, length: Int) throws -> Data {
        let handle = try FileHandle(forReadingFrom: URL(fileURLWithPath: path))
        defer { try? handle.close() }
        try handle.seek(toOffset: UInt64(max(0, offset)))
        return try handle.read(upToCount: max(0, length)) ?? Data()
    }

    func writeData(_ data: Data, toPath path: String) throws {
        guard manager.fileExists(atPath: path) else {
            try data.write(to: URL(fileURLWithPath: path))
            return
        }
        let handle = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
        defer { try? handle.close() }
        try handle.truncate(atOffset: 0)
        try handle.write(contentsOf: data)
    }

    func copyItem(atPath source: String, toPath destination: String) throws {
        try manager.copyItem(atPath: source, toPath: destination)
    }

    func moveItem(atPath source: String, toPath destination: String) throws {
        try manager.moveItem(atPath: source, toPath: destination)
    }

    func createDirectory(atPath path: String) throws {
        try manager.createDirectory(atPath: path, withIntermediateDirectories: true)
    }

    func trashItem(atPath path: String) throws {
        try manager.trashItem(at: URL(fileURLWithPath: path), resultingItemURL: nil)
    }
}
