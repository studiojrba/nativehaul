import Foundation

/// How hard the Meebits energy pass leans in (ADR 0037, J.R 2026-11-09: "Nothing's permanent so we can dial it back
/// or lean in even more"). One dial position drives every energy token, so the design system holds at all three.
enum DesignIntensity: String, CaseIterable, Sendable {
    /// The pass as Ollie specced it.
    case specced
    /// Pushed past the spec: bigger type, stronger fields. The default until J.R picks.
    case leanedIn
    /// Everything turned up.
    case fullSend

    /// UserDefaults key for trying another position live, without a rebuild:
    /// `defaults write com.studiojrba.nativehaul design.intensity fullSend`.
    static let defaultsKey = "design.intensity"

    /// The position the app runs at: the UserDefaults override if set, otherwise ``leanedIn``.
    static var current: DesignIntensity {
        UserDefaults.standard.string(forKey: defaultsKey).flatMap(DesignIntensity.init(rawValue:)) ?? .leanedIn
    }

    /// Label used in render names and docs.
    var title: String {
        switch self {
        case .specced: "As specced"
        case .leanedIn: "Leaned in"
        case .fullSend: "Full send"
        }
    }
}
