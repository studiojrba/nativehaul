/// The three interface sounds (audio brief, spec §5). Their levels are final and they play at one shared gain.
enum UISound: String, CaseIterable, Sendable {
    /// Navigation or focus movement (sidebar selection, shelf focus).
    case navigate = "nav"
    /// Confirm or select, including launching a game (the A / Cross press).
    case confirm
    /// Back or cancel (the B / Circle press).
    case back

    /// The bundled file name, without extension.
    var resourceName: String {
        rawValue
    }

    /// The bundled file extension.
    static let resourceExtension = "wav"
}
