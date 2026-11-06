import Foundation

/// Which store a bottle install comes from. Slice 1 handles Steam only; Epic and GOG would add cases and their own
/// ``StoreClientInstalling`` implementations.
enum StoreGameReference: Equatable, Sendable {
    /// A Steam app.
    case steam(appID: Int)
}
