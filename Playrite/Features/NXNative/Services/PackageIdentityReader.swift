import Foundation

/// Reads a Switch package's title ID without keys or decryption (ADR 0023). Read-only, and only the file's header.
///
/// In order: the `[0100…][v65536]` tags in the file name (the usual naming); the ticket name inside an NSP/NSZ
/// (`<title ID><key gen>.tik`); the plain `.cnmt.xml` some NSPs carry (`<Id>` and `<Version>`). Anything else is left
/// unidentified, and the engine sorts it out when it builds.
struct PackageIdentityReader: Sendable {
    private static let headerBytes = 1 << 16
    private static let metadataBytes = 1 << 15
    private static let maximumEntryOffset = Int(UInt32.max)
    private static let pfsMagic = Data("PFS0".utf8)
    private static let pfsHeaderSize = 16
    private static let pfsEntrySize = 24
    private static let titleIDDigits = 16
    private static let countOffset = 4
    private static let stringTableSizeOffset = 8
    private static let entrySizeOffset = 8
    private static let entryNameOffset = 16
    private static var tagPattern: Regex<(Substring, Substring)> {
        /\[([0-9A-Fa-f]{16})\]/
    }

    private static var versionPattern: Regex<(Substring, Substring)> {
        /\[v(\d+)\]/
    }

    private static var xmlIDPattern: Regex<(Substring, Substring)> {
        /<Id>(0x[0-9A-Fa-f]{16})<\/Id>/
    }

    private static var xmlVersionPattern: Regex<(Substring, Substring)> {
        /<Version>(\d+)<\/Version>/
    }

    /// One file inside a PFS0 container.
    private struct Entry {
        let name: String
        let offset: Int
        let size: Int
    }

    private let files: any FileOperating

    /// Creates the reader.
    init(files: any FileOperating) {
        self.files = files
    }

    /// The package's identity, if it can be told.
    func identity(ofPackageAt path: String) -> PackageIdentity? {
        let name = (path as NSString).lastPathComponent
        if let match = name.firstMatch(of: Self.tagPattern), let titleID = SwitchTitleID(match.1) {
            return PackageIdentity(titleID: titleID, version: name.firstMatch(of: Self.versionPattern).flatMap {
                Int($0.1)
            })
        }
        return headerIdentity(path)
    }

    /// A readable game name from a package's file name: everything before the first `[` or `(` tag.
    static func gameName(fromFileName fileName: String) -> String {
        let stem = (fileName as NSString).deletingPathExtension
        let cut = stem.firstIndex { $0 == "[" || $0 == "(" } ?? stem.endIndex
        return stem[..<cut].replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespaces)
    }

    private func headerIdentity(_ path: String) -> PackageIdentity? {
        guard let read = try? files.readData(atPath: path, offset: 0, length: Self.headerBytes) else { return nil }
        let header = Data(read)
        guard header.count >= Self.pfsHeaderSize, header.prefix(Self.pfsMagic.count) == Self.pfsMagic,
              let entries = Self.entries(of: header)
        else { return nil }
        if let ticket = entries.first(where: { $0.name.hasSuffix(".tik") }) {
            return SwitchTitleID(ticket.name.prefix(Self.titleIDDigits))
                .map { PackageIdentity(titleID: $0, version: nil) }
        }
        return entries.first { $0.name.hasSuffix(".cnmt.xml") }.flatMap { metadataIdentity($0, in: path) }
    }

    private func metadataIdentity(_ entry: Entry, in path: String) -> PackageIdentity? {
        let length = min(entry.size, Self.metadataBytes)
        guard let data = try? files.readData(atPath: path, offset: entry.offset, length: length),
              let text = String(bytes: data, encoding: .utf8),
              let id = text.firstMatch(of: Self.xmlIDPattern),
              let titleID = SwitchTitleID(id.1)
        else { return nil }
        let version = text.firstMatch(of: Self.xmlVersionPattern).flatMap { Int($0.1) }
        return PackageIdentity(titleID: titleID, version: version)
    }

    /// The PFS0 entries, with offsets from the start of the file; `nil` when the header doesn't fit what was read.
    private static func entries(of header: Data) -> [Entry]? {
        let count = Int(header.uint32(at: countOffset))
        let tableStart = pfsHeaderSize + count * pfsEntrySize
        let tableEnd = tableStart + Int(header.uint32(at: stringTableSizeOffset))
        guard tableEnd <= header.count else { return nil }
        return (0 ..< count).compactMap { index in
            let entry = pfsHeaderSize + index * pfsEntrySize
            let nameStart = tableStart + Int(header.uint32(at: entry + entryNameOffset))
            guard nameStart < tableEnd else { return nil }
            let nameEnd = header[nameStart ..< tableEnd].firstIndex(of: 0) ?? tableEnd
            let offset = min(Int(clamping: header.uint64(at: entry)), maximumEntryOffset)
            return Entry(
                name: String(bytes: header[nameStart ..< nameEnd], encoding: .utf8) ?? "",
                offset: tableEnd + offset,
                size: Int(clamping: header.uint64(at: entry + entrySizeOffset))
            )
        }
    }
}
