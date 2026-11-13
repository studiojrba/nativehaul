import Foundation

/// A centred frost toast (spec §3.7): a jump letter in the display face, or a short message.
enum CouchToast: Equatable, Sendable {
    /// The letter a jump landed on (120pt display).
    case letter(String)
    /// "You're home", "Already home" (32pt).
    case message(String)

    /// "You're home" (B on Home).
    static let youreHome = CouchToast.message("You’re home")
    /// "Already home" (Home on Home).
    static let alreadyHome = CouchToast.message("Already home")

    /// The text shown.
    var text: String {
        switch self {
        case let .letter(text), let .message(text): text
        }
    }

    /// `true` for a jump letter.
    var isLetter: Bool {
        if case .letter = self {
            return true
        }
        return false
    }
}
