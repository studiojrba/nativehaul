import Foundation

/// Where the tour stands, remembered across launches (ADR 0040) so an exited tour resumes where it left off.
enum GuideProgress: Codable, Equatable, Sendable {
    /// Never started: it starts on first launch.
    case notStarted
    /// Showing a step.
    case active(GuideStep)
    /// Exited at a step; can be resumed.
    case paused(GuideStep)
    /// Finished (or dismissed for good). Only "Run setup again" brings it back.
    case finished
}
