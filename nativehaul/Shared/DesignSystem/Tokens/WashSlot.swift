/// The fixed game-palette wash slots (spec §2.2): theme constants with a light and a dark value each, used for screen
/// background washes and Settings group tints.
enum WashSlot: String, CaseIterable, Sendable {
    /// Soft sky.
    case sky
    /// Soft blush.
    case blush
    /// Soft mint.
    case mint
    /// Soft butter.
    case butter
    /// The palette cream.
    case cream
    /// Soft peach.
    case peach
    /// Soft lilac (warm-shifted in the evening).
    case lilac
}
