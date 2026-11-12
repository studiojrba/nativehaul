import Foundation

/// One button prompt in the TV bottom bar.
struct TVPrompt: Equatable, Identifiable, Sendable {
    /// What the button does.
    let action: ControllerAction
    /// What it says ("Play").
    let label: String

    /// Stable identity.
    var id: String {
        label
    }
}
