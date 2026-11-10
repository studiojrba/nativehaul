import CryptoKit
import Foundation

/// How RetroAchievements identifies a cartridge ROM (its game-identification rules, ADR 0047): an MD5 of the file,
/// after removing what a dump tool may have added.
enum RomHashRule: Equatable, Sendable {
    /// MD5 of the whole file (Game Boy, Game Boy Color, Game Boy Advance).
    case wholeFile
    /// NES: a file starting with the iNES header `NES\u{1A}` drops its first 16 bytes.
    case nes
    /// SNES: a file 512 bytes past a multiple of 8 KB drops its 512-byte copier header.
    case snes
    /// Nintendo 64: byte-swapped (`.v64`) and little-endian (`.n64`) dumps are hashed as their big-endian (`.z64`)
    /// form.
    case nintendo64

    // File-format signatures are data, not tuning values, so the magic-number rule is off for these lines only.
    // swiftlint:disable no_magic_numbers
    private static let inesMagic: [UInt8] = [0x4E, 0x45, 0x53, 0x1A]
    private static let inesHeaderSize = 16
    private static let copierHeaderSize = 512
    private static let snesBlock = 8192
    private static let z64Magic: [UInt8] = [0x80, 0x37, 0x12, 0x40]
    private static let v64Magic: [UInt8] = [0x37, 0x80, 0x40, 0x12]
    private static let n64Magic: [UInt8] = [0x40, 0x12, 0x37, 0x80]
    // swiftlint:enable no_magic_numbers
    private static let wordSize = 4
    private static let halfWordSize = 2

    /// The lowercase hex MD5 RetroAchievements uses for `data`.
    func hash(of data: Data) -> String {
        Insecure.MD5.hash(data: normalized(data)).map { String(format: "%02x", $0) }.joined()
    }

    private func normalized(_ data: Data) -> Data {
        switch self {
        case .wholeFile:
            return data
        case .nes:
            return data.prefix(Self.inesMagic.count).elementsEqual(Self.inesMagic)
                ? data.dropFirst(Self.inesHeaderSize)
                : data
        case .snes:
            return data.count % Self.snesBlock == Self.copierHeaderSize ? data.dropFirst(Self.copierHeaderSize) : data
        case .nintendo64:
            let magic = Array(data.prefix(Self.wordSize))
            if magic == Self.v64Magic {
                return Self.swapped(data, every: Self.halfWordSize)
            }
            if magic == Self.n64Magic {
                return Self.swapped(data, every: Self.wordSize)
            }
            return data
        }
    }

    /// Reverses the bytes of each `size`-byte group (2 for `.v64`, 4 for `.n64`).
    private static func swapped(_ data: Data, every size: Int) -> Data {
        var bytes = [UInt8](data)
        var index = 0
        while index + size <= bytes.count {
            bytes[index ..< index + size].reverse()
            index += size
        }
        return Data(bytes)
    }
}
