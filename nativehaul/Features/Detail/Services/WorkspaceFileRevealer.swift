import AppKit

/// Reveals files with `NSWorkspace` — Finder opens the folder and selects the item; nativehaul reads nothing.
struct WorkspaceFileRevealer: FileRevealing {
    func reveal(path: String) {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }
}
