import Foundation

/// A face button by physical position. Apple's GameController reports face buttons by position (`buttonA` is the
/// bottom one on every controller), whatever letter is printed on it.
enum FaceButton: Equatable, Sendable {
    /// Bottom (GameController `buttonA`).
    case south
    /// Right (`buttonB`).
    case east
    /// Left (`buttonX`).
    case west
    /// Top (`buttonY`).
    case north
}
