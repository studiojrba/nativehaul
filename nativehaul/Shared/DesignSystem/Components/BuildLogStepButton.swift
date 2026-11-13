import SwiftUI

/// The build log's plus or minus button: a small round button, quiet until hovered, faded when it can't act.
struct BuildLogStepButton: View {
    /// SF Symbol.
    let symbol: String
    /// Spoken label.
    let label: String
    /// Whether it can act.
    let isEnabled: Bool
    /// The action.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: ShellLayout.BuildLog.stepIcon, weight: .medium))
                .foregroundStyle(Theme.lamp.opacity(
                    isHovered ? ShellLayout.BuildLog.stepHoverOpacity : ShellLayout.BuildLog.headerOpacity
                ))
                .frame(width: ShellLayout.BuildLog.stepSize, height: ShellLayout.BuildLog.stepSize)
                .background {
                    if isHovered {
                        Circle().fill(Theme.lamp.opacity(ShellLayout.BuildLog.stepHoverFill))
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : ShellLayout.BuildLog.stepDisabledOpacity)
        .onHover { isHovered = $0 && isEnabled }
        .accessibilityLabel(label)
    }
}

#Preview {
    HStack {
        BuildLogStepButton(symbol: "minus", label: "Show less", isEnabled: false) {}
        BuildLogStepButton(symbol: "plus", label: "Show more", isEnabled: true) {}
    }
    .padding(DesignTokens.Spacing.lg)
    .background(Theme.bezel)
}
