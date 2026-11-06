import Foundation

/// Asks macOS about an app's signature. Live: ``CodesignSignatureAssessor``; mock: ``FixedSignatureAssessor``.
protocol SignatureAssessing: Sendable {
    /// The app's signature status.
    func assess(appAt path: String) async -> SignatureStatus
}
