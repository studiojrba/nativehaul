import Foundation

/// A step in a page's fade-and-rise entrance (ADR 0040): earlier steps arrive first.
enum RiseStep: Int, Sendable {
    case first, second, third, fourth, fifth, sixth
}
