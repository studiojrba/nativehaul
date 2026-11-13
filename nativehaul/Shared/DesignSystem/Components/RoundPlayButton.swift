import SwiftUI

/// The small round Play on shelf tiles (spec §3.1 Continue card): `ink` disc with a `paper` glyph that turns accent on
/// hover. On a shelf, the click that ends a drag is ignored.
struct RoundPlayButton: View {
    /// Disc diameter.
    var size: CGFloat = ShellLayout.Continue.playSize
    /// Glyph size.
    var iconSize: CGFloat = ShellLayout.Continue.playIcon
    /// Whether the card it sits on is hovered (the whole card lights it).
    var isHighlighted = false
    /// Starts the game.
    let action: () -> Void

    @State private var isHovered = false
    @Environment(\.shelfController) private var shelf
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            if shelf?.allowsTap() ?? true {
                action()
            }
        } label: {
            Image(systemName: "play.fill")
                .font(.system(size: iconSize))
                .foregroundStyle(isLit ? Theme.onAccent : Theme.paper)
                .frame(width: size, height: size)
                .background(Circle().fill(isLit ? Theme.accent : Theme.ink))
                .contentShape(Circle())
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.background), value: isLit)
        .accessibilityLabel("Play")
    }

    private var isLit: Bool {
        isHovered || isHighlighted
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.lg) {
            RoundPlayButton {}
            RoundPlayButton(isHighlighted: true) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
