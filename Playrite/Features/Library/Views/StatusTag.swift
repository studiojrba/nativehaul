import SwiftUI

/// Tag showing a ``GameStatus``.
struct StatusTag: View {
    /// Status to show.
    let status: GameStatus

    var body: some View {
        TagLabel(text: status.displayName, symbolName: status.symbolName, tint: status.tint)
    }
}

#Preview {
    VStack { ForEach(GameStatus.allCases) { StatusTag(status: $0) } }
        .padding(DesignTokens.Spacing.lg)
}
