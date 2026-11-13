import SwiftUI

/// The menu bar (ADR 0055): everything the 0.1.0 nav island leaves out stays one menu away — adding, importing,
/// exporting and tidying the library, the Library filters, the Go menu with ⌘1–⌘4 for the island's screens, ⌘K for
/// search, ⌘[ for Back, and ⌥⌘1–⌥⌘4 for Series, Collections, Stats and Playtime Tracking (each in a sheet).
struct ShellCommands: Commands {
    @FocusedValue(\.shellViewModel) private var shell
    @FocusedValue(\.libraryViewModel) private var library

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Add Game…") { shell?.isAddingGame = true }
                .keyboardShortcut("n")
                .disabled(shell == nil)
        }
        CommandMenu("Library") {
            libraryItems
        }
        CommandMenu("Go") {
            goItems
        }
    }

    @ViewBuilder private var libraryItems: some View {
        Button("Import Library…") { shell?.isImporting = true }
            .disabled(shell == nil)
        Button("Export Library…") {
            shell?.exportDocument = library?.exportData().map(LibraryJSONDocument.init(data:))
        }
        .disabled(shell == nil || library == nil)
        Divider()
        Button("Scan Game Folders") {
            if let library {
                Task { await library.scanGameFolders() }
            }
        }
        .disabled(library?.canScanFolders != true)
        SettingsLink { Text("Configure Game Folders…") }
        Divider()
        Button("Merge Duplicate Games…") { shell?.isMergingDuplicates = true }
            .disabled(shell == nil)
        Button("Fetch Missing Metadata") {
            if let library {
                Task { await library.fetchMissingMetadata() }
            }
        }
        .disabled(library?.canFetchMetadata != true)
        Divider()
        if let library {
            Picker("Show", selection: Bindable(library).filter.section) {
                ForEach(LibrarySection.allCases) { Text($0.title).tag($0) }
            }
            Toggle("Installed Only", isOn: Bindable(library).filter.installedOnly)
        }
    }

    @ViewBuilder private var goItems: some View {
        ForEach(Array(NavItem.allCases.enumerated()), id: \.element.id) { offset, item in
            Button(item.title) {
                shell?.go(to: item.screen)
            }
            .keyboardShortcut(KeyEquivalent(Character(String(offset + 1))))
            .disabled(shell == nil)
        }
        Button("Back") { shell?.back() }
            .keyboardShortcut("[")
            .disabled(shell?.screen != .detail)
        Divider()
        Button("Find a Game…") { shell?.requestSearchFocus() }
            .keyboardShortcut("k")
            .disabled(shell == nil)
        Divider()
        ForEach(ToolSheet.allCases) { tool in
            Button(tool.title) { shell?.presentedTool = tool }
                .keyboardShortcut(KeyEquivalent(tool.keyEquivalent), modifiers: [.command, .option])
                .disabled(shell == nil)
        }
    }
}
