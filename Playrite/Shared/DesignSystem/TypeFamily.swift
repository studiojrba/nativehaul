import Foundation

/// The two candidate families for all type (J.R, 2026-11-09 20:48, ADR 0041): Inter first, SF Pro (standard, not
/// rounded) the alternative. Both are clean neutral grotesques; J.R picks from renders before the family is locked.
enum TypeFamily: String, CaseIterable, Sendable {
    /// Inter (bundled, SIL Open Font License).
    case inter
    /// SF Pro, the system font's standard design.
    case sfPro
}
