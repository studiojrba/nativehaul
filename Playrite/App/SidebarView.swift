import SwiftUI

/// App sidebar: library sections with counts. Later features add their own sections here.
struct SidebarView: View {
    /// Selected destination.
    @Binding var selection: SidebarDestination?
    /// Library state for counts.
    let libraryViewModel: LibraryViewModel

    var body: some View {
        List(selection: $selection) {
            Section("Library") {
                ForEach(LibrarySection.allCases) { section in
                    Label(section.title, systemImage: section.symbolName)
                        .badge(libraryViewModel.count(for: section))
                        .tag(SidebarDestination.library(section))
                }
            }
        }
        .navigationSplitViewColumnWidth(
            min: DesignTokens.Layout.sidebarMinWidth,
            ideal: DesignTokens.Layout.sidebarMinWidth
        )
    }
}

#Preview {
    SidebarView(selection: .constant(.library(.all)), libraryViewModel: AppEnvironment.preview.makeLibraryViewModel())
}
