import Foundation

/// One prompt in the couch prompt bar (spec §3.7): its glyph buttons and a label ("A Play", "L R Switch game").
struct CouchPrompt: Equatable, Sendable, Identifiable {
    /// The buttons, drawn side by side.
    let buttons: [CouchButton]
    /// What they do.
    let label: String

    /// Prompts are told apart by label.
    var id: String {
        label
    }
}
