import Foundation

/// TV mode settings (ADR 0052). Choosing a default mode at onboarding and starting in TV mode are later milestones.
struct TVModePreferences: Codable, Equatable, Sendable {
    /// Library layout.
    var layout: TVLayout = .shelf
}
