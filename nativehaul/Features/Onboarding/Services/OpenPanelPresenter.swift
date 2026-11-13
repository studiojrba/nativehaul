import AppKit
import UniformTypeIdentifiers

/// Live ``FilePanelPresenting``: `NSOpenPanel`, as a sheet on the key window when there is one.
@MainActor
final class OpenPanelPresenter: FilePanelPresenting {
    /// Creates the presenter.
    init() {}

    func chooseFolder() async -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.prompt = "Choose"
        panel.message = "Pick the folder that holds your Switch files and ROMs."
        return await present(panel)
    }

    func chooseFile(allowedExtensions extensions: [String]) async -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Choose"
        let types = extensions.compactMap { UTType(filenameExtension: $0) }
        if !types.isEmpty {
            panel.allowedContentTypes = types + [.data]
        }
        return await present(panel)
    }

    private func present(_ panel: NSOpenPanel) async -> URL? {
        let response: NSApplication.ModalResponse = if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            await panel.beginSheetModal(for: window)
        } else {
            panel.runModal()
        }
        return response == .OK ? panel.url : nil
    }
}
