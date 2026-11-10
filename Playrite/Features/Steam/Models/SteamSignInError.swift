import Foundation

/// Why Steam sign-in did not complete. Messages are plain and never imply library access.
enum SteamSignInError: Error, Equatable, LocalizedError {
    /// The user closed the Steam window.
    case cancelled
    /// The reply wasn't a Steam sign-in response.
    case notASteamResponse
    /// The reply was for a different return address, or came from somewhere other than Steam.
    case untrustedResponse
    /// Steam's reply didn't contain a valid Steam account.
    case invalidIdentity
    /// Steam said the reply was not genuine.
    case rejectedBySteam
    /// Steam couldn't be reached to confirm the sign-in.
    case couldNotConfirm
    /// The browser sign-in wasn't finished in time (for example, the tab was closed).
    case timedOut
    /// NX Shelf couldn't open its private sign-in listener on this Mac.
    case couldNotListen

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case .cancelled: "Sign-in was cancelled."
        case .notASteamResponse, .untrustedResponse, .invalidIdentity:
            "Steam's sign-in reply couldn't be trusted, so you weren't signed in. Please try again."
        case .rejectedBySteam: "Steam couldn't confirm this sign-in, so you weren't signed in. Please try again."
        case .couldNotConfirm: "Couldn't reach Steam to confirm the sign-in. Check your connection and try again."
        case .timedOut:
            "The sign-in wasn't finished in the browser, so you weren't signed in. Press Sign in through Steam to "
                + "try again."
        case .couldNotListen:
            "NX Shelf couldn't open its private sign-in address on this Mac. Try again, or enter your details "
                + "manually below."
        }
    }
}
