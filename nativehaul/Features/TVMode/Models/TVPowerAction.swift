import Foundation

/// Power actions in the TV Start/Options menu (ADR 0052). Each one asks for confirmation first.
enum TVPowerAction: Equatable, Sendable {
    case sleep
    case restart
    case shutDown

    /// Menu title.
    var title: String {
        switch self {
        case .sleep: "Sleep"
        case .restart: "Restart"
        case .shutDown: "Shut Down"
        }
    }

    /// The confirmation question.
    var confirmation: String {
        switch self {
        case .sleep: "Put the Mac to sleep?"
        case .restart: "Restart the Mac? Other apps will be asked to quit first."
        case .shutDown: "Shut down the Mac? Other apps will be asked to quit first."
        }
    }
}
