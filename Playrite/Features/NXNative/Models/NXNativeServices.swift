import Foundation

/// Bundle of the NXNative module's services, injected into its view models.
struct NXNativeServices: Sendable {
    /// File operations (no delete, no empty-Trash).
    let files: any FileOperating
    /// Free-space source.
    let disk: any DiskSpaceProviding
    /// External engine runner.
    let runner: any BuildEngineRunning
    /// Audit log.
    let audit: any AuditLogging
    /// Troubleshooting cases.
    let knowledgeBase: any KnowledgeBaseProviding
    /// Folder for script backups.
    let backupDirectory: String
    /// NX Shelf's own bundle path (to prove the engine is external).
    let appBundlePath: String
    /// Home folder used to resolve the `~` search paths of ``NXNativeLocator``.
    var homeDirectory = NSHomeDirectory()

    /// Detects the engine and `prod.keys` the user already has.
    var locator: NXNativeLocator {
        NXNativeLocator(files: files, homeDirectory: homeDirectory)
    }
}
