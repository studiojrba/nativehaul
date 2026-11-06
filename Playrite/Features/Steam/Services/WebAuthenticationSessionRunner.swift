import AppKit
import AuthenticationServices

/// Live ``SteamWebAuthenticating`` using `ASWebAuthenticationSession`. Steam's page runs in the system browser
/// session, so Playrite never sees the user's Steam password.
@MainActor
final class WebAuthenticationSessionRunner: NSObject, SteamWebAuthenticating {
    private var session: ASWebAuthenticationSession?

    func authenticate(url: URL, callbackScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callback: .customScheme(callbackScheme)) { url, error in
                if let url {
                    continuation.resume(returning: url)
                } else if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: SteamSignInError.cancelled)
                } else {
                    continuation.resume(throwing: SteamSignInError.notASteamResponse)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.session = session
            if !session.start() {
                self.session = nil
                continuation.resume(throwing: SteamSignInError.notASteamResponse)
            }
        }
    }
}

extension WebAuthenticationSessionRunner: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            NSApp.keyWindow ?? NSApp.windows.first ?? NSWindow()
        }
    }
}
