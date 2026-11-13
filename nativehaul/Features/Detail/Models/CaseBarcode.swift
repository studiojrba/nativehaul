import Foundation

/// The decorative barcode on the case's back (spec §3.3): one bar per hex digit of the game's ID, `(digit % 3) + 1`
/// points wide. It encodes nothing; it only makes each case look like its own.
enum CaseBarcode {
    /// Bars at most (a Switch title ID has 16 digits).
    static let maximumBars = 16
    private static let widthSteps = 3
    private static let radix = 16

    /// Bar widths (points) for `identifier`: its hex digits, other characters skipped.
    static func bars(for identifier: String) -> [Int] {
        identifier.compactMap { Int(String($0), radix: radix) }
            .prefix(maximumBars)
            .map { $0 % widthSteps + 1 }
    }
}
