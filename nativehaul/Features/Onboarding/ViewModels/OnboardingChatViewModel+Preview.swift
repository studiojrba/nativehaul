import Foundation

extension OnboardingChatViewModel {
    /// The folder the shelf scene's bar shows: the chosen one, or — while the question is open — the one the hovered
    /// or focused answer would use (note 2). `nil` reads "No folder chosen yet".
    var previewFolderLabel: String? {
        if beat == .found {
            return facts.scannedFolderLabel
        }
        guard beat == .games, let hovered = hoveredAction else { return nil }
        switch hovered.effect {
        case let .useFolder(path): return OnboardingScript.abbreviate(path)
        case .keepFolders: return OnboardingScript.folderList(facts.configuredFolders)
        default: return nil
        }
    }
}
