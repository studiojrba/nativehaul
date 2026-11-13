import SwiftUI
import UniformTypeIdentifiers

/// Settings → Directories (spec §3.5): every game folder (adding one scans it straight away), where Switch builds go,
/// and the user's keys file — the real detected path, a **Valid** badge only when the file is really there.
struct DirectoriesSettingsGroup: View {
    /// The directories.
    let viewModel: DirectoriesSettingsViewModel

    var body: some View {
        SettingsGroup(
            symbolName: "folder",
            tint: .butter,
            title: "Directories",
            note: "Where your games are and where they go."
        ) {
            if viewModel.folders.folders.isEmpty {
                SettingsRow(label: "Games folder", sub: "Not chosen yet") {
                    FilePickerButton(title: "Choose…", contentTypes: [.folder]) { url in
                        Task { await viewModel.folders.addAndScan([url]) }
                    }
                }
            }
            ForEach(Array(viewModel.folders.folders.enumerated()), id: \.element) { index, folder in
                folderRow(folder, isFirst: index == 0)
            }
            SettingsRow(label: "Look for new games", sub: scanLine) {
                HStack(spacing: ShellLayout.Settings.controlGap) {
                    FilePickerButton(title: "Add a folder…", contentTypes: [.folder]) { url in
                        Task { await viewModel.folders.addAndScan([url]) }
                    }
                    Button("Scan now") { Task { await viewModel.folders.scan() } }
                        .buttonStyle(CreamPillButtonStyle())
                        .disabled(viewModel.folders.isScanning)
                }
            }
            SettingsRow(
                label: "Install location",
                sub: viewModel.installLocation,
                isSubMonospaced: true,
                footnote: "Where your Switch builds go"
            ) {
                FilePickerButton(title: "Change…", contentTypes: [.folder]) { viewModel.chooseInstallLocation($0) }
            }
            keysRow
        }
        .task { await viewModel.refresh() }
    }

    private func folderRow(_ folder: String, isFirst: Bool) -> some View {
        SettingsRow(
            label: isFirst ? "Games folder" : "Also looking in",
            sub: (folder as NSString).abbreviatingWithTildeInPath,
            isSubMonospaced: true
        ) {
            HStack(spacing: ShellLayout.Settings.controlGap) {
                if viewModel.folders.folders.count > 1 {
                    QuietTextButton(title: "Remove") { viewModel.folders.remove(folder) }
                }
                FilePickerButton(title: "Change…", contentTypes: [.folder]) { url in
                    Task { await viewModel.folders.replace(folder, with: url) }
                }
            }
        }
    }

    private var keysRow: some View {
        SettingsRow(
            label: "Library key",
            sub: viewModel.keys.displayPath,
            isSubMonospaced: viewModel.keys.path != nil,
            badge: viewModel.keys.isValid ? "Valid" : nil,
            footnote: KeysFileStatus.purpose
        ) {
            HStack(spacing: ShellLayout.Settings.controlGap) {
                if viewModel.keys.isOverride {
                    QuietTextButton(title: "Use detected") { Task { await viewModel.useDetectedKeys() } }
                }
                FilePickerButton(title: "Change…", contentTypes: keysTypes) { url in
                    Task { await viewModel.chooseKeysFile(url) }
                }
            }
        }
    }

    private var keysTypes: [UTType] {
        [UTType(filenameExtension: "keys"), .data].compactMap(\.self)
    }

    private var scanLine: String {
        if viewModel.folders.isScanning {
            return "Looking…"
        }
        if let error = viewModel.folders.errorMessage {
            return error
        }
        return viewModel.folders.lastSummary?.description ?? "Adding a folder looks through it straight away."
    }
}

#Preview {
    let environment = AppEnvironment.preview
    AppearancePreviewPair {
        DirectoriesSettingsGroup(viewModel: environment.makeDirectoriesSettingsViewModel())
            .padding(DesignTokens.Spacing.xl)
    }
}
