import SwiftUI

/// Tag naming a ``PlaytimeSource``. Every playtime figure in the UI is shown with one.
struct PlaytimeSourceTag: View {
    /// Source to label.
    let source: PlaytimeSource

    var body: some View {
        TagLabel(text: source.label, symbolName: source.symbolName, tint: source.tint)
    }
}

#Preview {
    VStack { ForEach(PlaytimeSource.allCases) { PlaytimeSourceTag(source: $0) } }
        .padding(DesignTokens.Spacing.lg)
}
