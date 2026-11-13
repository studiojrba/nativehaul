import SwiftUI

/// The floating top bar (spec §3.0): the wordmark pill (with the window's buttons), the search field centred, and the
/// Couch mode pill. Empty space between the pills lets clicks through to the page.
struct TopBar: View {
    /// The shell.
    let shell: ShellViewModel
    /// The library to search.
    let games: [Game]

    var body: some View {
        HStack(spacing: ShellLayout.Chrome.pillGap) {
            WordmarkPill()
            Spacer(minLength: 0)
            SearchPill(shell: shell, games: games)
                .frame(maxWidth: ShellLayout.TopBar.searchMaxWidth)
                .zIndex(1)
            Spacer(minLength: 0)
            CouchModePill { shell.enterCouch() }
        }
        .padding(.horizontal, ShellLayout.TopBar.side)
        .padding(.top, ShellLayout.TopBar.top)
    }
}

#Preview {
    AppearancePreviewPair {
        TopBar(shell: ShellViewModel { AppEnvironment.preview.makeGameLaunchViewModel(for: $0) }, games: [])
            .frame(maxHeight: .infinity, alignment: .top)
    }
}
