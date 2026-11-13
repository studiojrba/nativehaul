import Foundation

/// Shows the macOS open panel for onboarding's picks (note 2): folders only for the games folder, a file for the
/// library key. The pick is the user's consent (ADR 0026). Live: ``OpenPanelPresenter``; mock: ``MockFilePanel``.
@MainActor
protocol FilePanelPresenting: AnyObject {
    /// Asks for a folder; `nil` when cancelled.
    func chooseFolder() async -> URL?
    /// Asks for a file with one of `extensions` (any file when empty); `nil` when cancelled.
    func chooseFile(allowedExtensions extensions: [String]) async -> URL?
}
