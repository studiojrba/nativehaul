import SwiftUI

/// A confident empty state (ADR 0025): one quiet symbol, a big display title, a calm sentence and an
/// optional action.
struct EmptyStateView<Actions: View>: View {
    /// Big title.
    let title: String
    /// SF Symbol, drawn quietly (the accent is spent only on Play, nav and links, ADR 0037).
    let symbolName: String
    /// One plain sentence.
    var message: String?
    /// Optional buttons.
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: symbolName)
                .font(DesignTokens.Typography.display)
                .foregroundStyle(Theme.secondaryText)
            Text(title)
                .font(DesignTokens.Typography.display)
                .tracking(DesignTokens.Typography.displayTracking)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            actions()
        }
        .padding(DesignTokens.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension EmptyStateView where Actions == EmptyView {
    /// An empty state without actions.
    init(title: String, symbolName: String, message: String? = nil) {
        self.init(title: title, symbolName: symbolName, message: message) { EmptyView() }
    }
}

#Preview {
    EmptyStateView(title: "No games yet", symbolName: "square.grid.2x2", message: "Add your game folders.")
        .background(Theme.canvas)
}
