import SwiftUI

/// The top bar's search field (spec §3.0): "Find a game…" with a `⌘K` chip (a clear button once there is text) and a
/// live results dropdown 56pt below. ⌘K focuses it from anywhere (the Go menu bumps
/// ``ShellViewModel/searchFocusRequest``);
/// Return opens the first result; Esc clears and leaves.
struct SearchPill: View {
    /// The shell (query, focus requests, opening a result).
    @Bindable var shell: ShellViewModel
    /// The library to search.
    let games: [Game]

    @FocusState private var isFocused: Bool

    var body: some View {
        let results = shell.searchResults(in: games)
        HStack(spacing: ShellLayout.Chrome.innerGap) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: ShellLayout.TopBar.searchIcon))
                .foregroundStyle(Theme.inkMute)
            TextField("Find a game…", text: $shell.searchQuery)
                .textFieldStyle(.plain)
                .font(Typeface.sans(TypeStyle.Size.body))
                .foregroundStyle(Theme.ink)
                .focused($isFocused)
                .onSubmit {
                    if let first = results.first {
                        shell.selectSearchResult(first)
                    }
                }
                .onExitCommand {
                    shell.searchQuery = ""
                    isFocused = false
                }
            trailingAccessory
        }
        .padding(.horizontal, ShellLayout.Chrome.pillPadding)
        .frame(height: ShellLayout.TopBar.pillHeight)
        .frostedGlass()
        .elevation(.small)
        .overlay(alignment: .top) {
            if isFocused, !shell.searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
                SearchResultsPanel(query: shell.searchQuery, results: results) { shell.selectSearchResult($0) }
                    .offset(y: ShellLayout.TopBar.resultsOffset)
            }
        }
        .onChange(of: shell.searchFocusRequest) { isFocused = true }
    }

    @ViewBuilder private var trailingAccessory: some View {
        if shell.searchQuery.isEmpty {
            Text("⌘K")
                .font(Typeface.sans(TypeStyle.Size.micro))
                .foregroundStyle(Theme.inkMute)
                .padding(.horizontal, ShellLayout.Chrome.kbdHorizontal)
                .padding(.vertical, ShellLayout.Chrome.kbdVertical)
                .background(
                    RoundedRectangle(cornerRadius: ShellLayout.TopBar.kbdRadius, style: .continuous)
                        .fill(Theme.ink.opacity(ShellLayout.TopBar.kbdFillOpacity))
                )
                .accessibilityHidden(true)
        } else {
            Button {
                shell.searchQuery = ""
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: ShellLayout.Chrome.clearIcon))
                    .foregroundStyle(Theme.inkMute)
            }
            .buttonStyle(.plain)
            .pointerStyle(.link)
            .accessibilityLabel("Clear")
        }
    }
}

#Preview {
    AppearancePreviewPair {
        SearchPill(shell: ShellViewModel { AppEnvironment.preview.makeGameLaunchViewModel(for: $0) }, games: [])
            .frame(width: ShellLayout.TopBar.searchMaxWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
