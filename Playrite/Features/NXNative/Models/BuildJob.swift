import Foundation

/// A queued conversion of one staged title.
struct BuildJob: Identifiable, Equatable, Sendable {
    /// Identity.
    let id: UUID
    /// Absolute path to the staged title file.
    var sourcePath: String
    /// Title information.
    var title: TitleInfo
    /// Current state.
    var status: BuildStatus = .queued
    /// When it was queued.
    let createdAt: Date
    /// Latest preflight report.
    var preflight: PreflightReport?
    /// Streamed output.
    var log: [BuildLogLine] = []
    /// Cleanup plan awaiting approval.
    var cleanupPlan: CleanupPlan?
    /// Failure description.
    var failureReason: String?

    /// Creates a job.
    init(id: UUID = UUID(), sourcePath: String, title: TitleInfo, createdAt: Date = .now) {
        self.id = id
        self.sourcePath = sourcePath
        self.title = title
        self.createdAt = createdAt
    }
}
