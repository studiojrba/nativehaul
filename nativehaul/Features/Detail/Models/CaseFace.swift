import CoreGraphics

/// The six faces of the case on Detail (spec §3.3): front and back covers, the spine (right), the far side (left) and
/// the top and bottom edges.
enum CaseFace: CaseIterable, Sendable {
    /// The front cover.
    case front
    /// The back cover.
    case back
    /// The spine, on the right.
    case spine
    /// The other side.
    case side
    /// The top edge.
    case top
    /// The bottom edge.
    case bottom

    /// The face's size for a case `width` × `height` × `depth`.
    func size(width: CGFloat, height: CGFloat, depth: CGFloat) -> CGSize {
        switch self {
        case .front, .back: CGSize(width: width, height: height)
        case .spine, .side: CGSize(width: depth, height: height)
        case .top, .bottom: CGSize(width: width, height: depth)
        }
    }
}
