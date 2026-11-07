import SwiftUI

/// A confident empty state (ADR 0025): one accent-coloured symbol, a big display title, a calm sentence and an
/// optional action.
struct EmptyStateView<Actions: View>: View {
    /// Big title.
    let title: String
    /// SF Symbol, drawn in the accent (the one pop on an empty screen).
    let symbolName: String
    /// One plain sentence.
    var message: String?
    /// Optional buttons.
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: symbolName)
                .font(DesignTokens.Typography.display)
                .foregroundStyle(Theme.accent)
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
    EmptyStateView(title: "No games yet", symbolName: "square.grid.2x2", message: "Add a game or sync Steam.")
        .background(Theme.canvas)
}
