import Foundation
import Synchronization

/// Mock ``FileOperating`` holding a virtual file tree. Trashed items are recorded, never destroyed.
final class InMemoryFileOperations: FileOperating {
    private struct State {
        var files: [String: Data] = [:]
        var directories: Set<String> = ["/"]
        var executables: Set<String> = []
        var trashed: [String] = []
    }

    private let state = Mutex(State())

    /// Creates an empty tree.
    init() {}

    /// Paths moved to the Trash, in order.
    var trashedPaths: [String] {
        state.withLock { $0.trashed }
    }

    /// Adds a file (creating parent directories). Marks it executable when requested.
    func addFile(_ path: String, contents: Data = Data(), executable: Bool = false) {
        state.withLock { state in
            Self.addParents(of: path, to: &state)
            state.files[path] = contents
            if executable {
                state.executables.insert(path)
            }
        }
    }

    /// Adds a directory and its parents.
    func addDirectory(_ path: String) {
        state.withLock { state in
            Self.addParents(of: path, to: &state)
            state.directories.insert(path)
        }
    }

    func fileExists(atPath path: String) -> Bool {
        state.withLock { $0.files[path] != nil || $0.directories.contains(path) }
    }

    func isDirectory(atPath path: String) -> Bool {
        state.withLock { $0.directories.contains(path) }
    }

    func isExecutableFile(atPath path: String) -> Bool {
        state.withLock { $0.executables.contains(path) && $0.files[path] != nil }
    }

    func contentsOfDirectory(atPath path: String) throws -> [String] {
        try state.withLock { state in
            guard state.directories.contains(path) else { throw FileOperationError.notFound(path) }
            let prefix = path.hasSuffix("/") ? path : path + "/"
            let children = (Array(state.files.keys) + Array(state.directories))
                .filter { $0.hasPrefix(prefix) && $0 != path }
                .map { String($0.dropFirst(prefix.count)) }
                .filter { !$0.contains("/") && !$0.isEmpty }
            return Array(Set(children)).sorted()
        }
    }

    func fileSize(atPath path: String) throws -> Int64 {
        try Int64(readData(atPath: path).count)
    }

    func readData(atPath path: String) throws -> Data {
        try state.withLock { state in
            guard let data = state.files[path] else { throw FileOperationError.notFound(path) }
            return data
        }
    }

    func writeData(_ data: Data, toPath path: String) throws {
        state.withLock { state in
            Self.addParents(of: path, to: &state)
            state.files[path] = data
        }
    }

    func copyItem(atPath source: String, toPath destination: String) throws {
        try transfer(from: source, to: destination, removingSource: false)
    }

    func moveItem(atPath source: String, toPath destination: String) throws {
        try transfer(from: source, to: destination, removingSource: true)
    }

    func createDirectory(atPath path: String) throws {
        addDirectory(path)
    }

    func trashItem(atPath path: String) throws {
        try state.withLock { state in
            guard state.files[path] != nil || state.directories.contains(path)
            else { throw FileOperationError.notFound(path) }
            Self.detach(path, from: &state)
            state.trashed.append(path)
        }
    }

    private func transfer(from source: String, to destination: String, removingSource: Bool) throws {
        try state.withLock { state in
            guard state.files[source] != nil || state.directories.contains(source)
            else { throw FileOperationError.notFound(source) }
            guard state.files[destination] == nil, !state.directories.contains(destination) else {
                throw FileOperationError.alreadyExists(destination)
            }
            Self.addParents(of: destination, to: &state)
            let rebase: (String) -> String = { destination + $0.dropFirst(source.count) }
            for (path, data) in state.files where path == source || path.hasPrefix(source + "/") {
                state.files[rebase(path)] = data
                if state.executables.contains(path) {
                    state.executables.insert(rebase(path))
                }
            }
            for path in state.directories where path == source || path.hasPrefix(source + "/") {
                state.directories.insert(rebase(path))
            }
            if removingSource {
                Self.detach(source, from: &state)
            }
        }
    }

    private static func detach(_ path: String, from state: inout State) {
        let isInside: (String) -> Bool = { $0 == path || $0.hasPrefix(path + "/") }
        state.files = state.files.filter { !isInside($0.key) }
        state.directories = state.directories.filter { !isInside($0) }
        state.executables = state.executables.filter { !isInside($0) }
    }

    private static func addParents(of path: String, to state: inout State) {
        var parent = (path as NSString).deletingLastPathComponent
        while !parent.isEmpty, parent != "/" {
            state.directories.insert(parent)
            parent = (parent as NSString).deletingLastPathComponent
        }
    }
}
