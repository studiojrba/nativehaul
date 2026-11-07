import Foundation

/// A Switch title ID and how it relates to its base game (ADR 0023).
///
/// A base game's ID ends in `000` with bit 12 clear (`…E000`). Its update is the same ID with `800` (`…E800`). Its DLC
/// are the base + `0x1000` + n for n ≥ 1 (`…F001`, `…F002`, …).
struct SwitchTitleID: Hashable, Sendable {
    /// What kind of content an ID names.
    enum Kind: Equatable, Sendable {
        case base
        case update
        case dlc
    }

    private static let hexDigits = 16
    private static let hexPrefixLength = 2
    private static let hexRadix = 16
    private static let contentMask: UInt64 = 0xFFF
    private static let updateBits: UInt64 = 0x800
    private static let dlcBit: UInt64 = 0x1000

    /// The 64-bit value.
    let value: UInt64

    /// Parses 16 hexadecimal digits (any letter case, optional `0x`).
    init?(_ text: some StringProtocol) {
        let text = String(text)
        let digits = text.hasPrefix("0x") || text.hasPrefix("0X") ? String(text.dropFirst(Self.hexPrefixLength)) : text
        guard digits.count == Self.hexDigits, let value = UInt64(digits, radix: Self.hexRadix) else { return nil }
        self.value = value
    }

    private init(value: UInt64) {
        self.value = value
    }

    /// Upper-case 16-digit form, as shown and passed to the engine.
    var hex: String {
        let digits = String(value, radix: Self.hexRadix, uppercase: true)
        return String(repeating: "0", count: Self.hexDigits - digits.count) + digits
    }

    /// Base game, update or DLC.
    var kind: Kind {
        if value & Self.dlcBit != 0, value & Self.contentMask != 0 {
            return .dlc
        }
        return value & Self.contentMask == Self.updateBits ? .update : .base
    }

    /// The base game this content belongs to.
    var baseID: SwitchTitleID {
        switch kind {
        case .base: self
        case .update: SwitchTitleID(value: value & ~Self.contentMask)
        case .dlc: SwitchTitleID(value: (value - Self.dlcBit) & ~Self.contentMask)
        }
    }
}
