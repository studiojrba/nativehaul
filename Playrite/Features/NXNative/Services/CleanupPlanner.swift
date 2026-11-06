import Foundation

/// Computes the post-build cleanup plan for a job's work directory. Pure: it only reads.
///
/// Rules: keep exactly one `.app` (renamed to the real title, never overwriting), keep the hidden library folder,
/// move every other leftover to the Trash, and move the emptied work directory to the Trash. Anything ambiguous is
/// left in place for manual review. The Trash is never emptied.
struct CleanupPlanner: Sendable {
    private static let appExtension = "app"
    private static let firstNameSuffix = 2
    private static let maxNameSuffix = 99
    private let files: any FileOperating

    /// Creates the planner.
    init(files: any FileOperating) {
        self.files = files
    }

    /// Plans cleanup of `workDirectory` for a title.
    func plan(
        workDirectory: String,
        titleName: String,
        titleID: String,
        configuration: EngineConfiguration
    ) -> CleanupPlan {
        let output = EngineConfiguration.expand(configuration.outputDirectory)
        let names = (try? files.contentsOfDirectory(atPath: workDirectory)) ?? []
        let path: (String) -> String = { (workDirectory as NSString).appendingPathComponent($0) }
        let apps = names.filter { ($0 as NSString).pathExtension == Self.appExtension }
        guard apps.count == 1, let app = apps.first else {
            let reason = apps.isEmpty ? "no .app produced" : "multiple .app bundles produced"
            return CleanupPlan(actions: names.map { .leave(path($0), reason: reason) })
        }
        var actions: [CleanupAction] = [.moveApp(
            from: path(app),
            to: availableAppPath(in: output, title: titleName, titleID: titleID)
        )]
        var leftAnything = false
        let library = configuration.hiddenLibraryFolderName
        for name in names where name != app {
            if name == library, library.hasPrefix(".") {
                let destination = (output as NSString).appendingPathComponent(library)
                if files.fileExists(atPath: destination) {
                    actions.append(.leave(path(name), reason: "a library folder already exists in the output folder"))
                    leftAnything = true
                } else {
                    actions.append(.moveLibrary(from: path(name), to: destination))
                }
            } else {
                actions.append(.moveToTrash(path(name)))
            }
        }
        if !leftAnything {
            actions.append(.moveToTrash(workDirectory))
        }
        return CleanupPlan(actions: actions)
    }

    /// Filesystem-safe app name from the real title.
    static func sanitizedName(_ title: String, fallback: String) -> String {
        let cleaned = title
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: " -")
            .trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: ".")))
        return cleaned.isEmpty ? fallback : cleaned
    }

    private func availableAppPath(in output: String, title: String, titleID: String) -> String {
        let base = Self.sanitizedName(title, fallback: titleID)
        let first = (output as NSString).appendingPathComponent("\(base).\(Self.appExtension)")
        guard files.fileExists(atPath: first) else { return first }
        for suffix in Self.firstNameSuffix ... Self.maxNameSuffix {
            let candidate = (output as NSString).appendingPathComponent("\(base) (\(suffix)).\(Self.appExtension)")
            if !files.fileExists(atPath: candidate) {
                return candidate
            }
        }
        return (output as NSString).appendingPathComponent("\(base) (\(titleID)).\(Self.appExtension)")
    }
}
