import Foundation
@testable import nativehaul

/// Folders in J.R's real naming style for the folder-first Add Build tests (ADR 0023).
enum FolderFirstFixtures {
    static let oppw = "/dl/OPPW4"
    static let oppwBase = "01008FE00E2F6000"

    /// One Piece Pirate Warriors 4: base, two updates, three DLC, plus junk the scan ignores.
    static func mixedFolder() -> InMemoryFileOperations {
        let files = InMemoryFileOperations()
        for name in [
            "One Piece Pirate Warriors 4 (US) [01008FE00E2F6000][v0] (12.05 GB).nsz",
            "One Piece Pirate Warriors 4 (US) [01008FE00E2F6800][v65536].nsp",
            "One Piece Pirate Warriors 4 (US) [01008FE00E2F6800][v1179648] (1.75 GB).nsz",
            "One Piece Pirate Warriors 4 (US) [DLC Luffy Costume Luffytaro] [01008FE00E2F7001][v0].nsp",
            "One Piece Pirate Warriors 4 (US) [DLC Land of Wano Pack] [01008FE00E2F7016][v65536].nsp",
            "One Piece Pirate Warriors 4 (US) [DLC Character Pack 8] [01008FE00E2F702C][v0].nsp",
            "._One Piece Pirate Warriors 4 (US) [01008FE00E2F6000][v0].nsz",
            "readme.txt",
        ] {
            files.addFile("\(oppw)/\(name)")
        }
        return files
    }

    /// A PFS0 (NSP) header holding the given entries, with each entry's bytes after the string table.
    static func pfs0(_ entries: [(name: String, data: Data)]) -> Data {
        let names = entries.map { Data($0.name.utf8) + Data([0]) }
        let table = names.reduce(Data(), +)
        var header = Data("PFS0".utf8)
        header.append(littleEndian: UInt32(entries.count))
        header.append(littleEndian: UInt32(table.count))
        header.append(littleEndian: UInt32(0))
        var dataOffset: UInt64 = 0
        var nameOffset: UInt32 = 0
        for (index, entry) in entries.enumerated() {
            header.append(littleEndian: dataOffset)
            header.append(littleEndian: UInt64(entry.data.count))
            header.append(littleEndian: nameOffset)
            header.append(littleEndian: UInt32(0))
            dataOffset += UInt64(entry.data.count)
            nameOffset += UInt32(names[index].count)
        }
        return header + table + entries.map(\.data).reduce(Data(), +)
    }
}

private extension Data {
    mutating func append(littleEndian value: some FixedWidthInteger) {
        Swift.withUnsafeBytes(of: value.littleEndian) { append(contentsOf: $0) }
    }
}
