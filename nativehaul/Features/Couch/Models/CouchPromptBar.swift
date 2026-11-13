import Foundation

/// The prompt bar's two groups (spec §3.7): what the focused thing does on the left, the way out on the right. An
/// empty bar is hidden (overlays carry their own prompts).
struct CouchPromptBar: Equatable, Sendable {
    /// Left group.
    var leading: [CouchPrompt] = []
    /// Right group.
    var trailing: [CouchPrompt] = []

    /// `true` when there is nothing to show.
    var isEmpty: Bool {
        leading.isEmpty && trailing.isEmpty
    }
}
