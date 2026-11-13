import SwiftUI

/// One carousel dot (see ``CarouselDots``).
struct CarouselDot: View {
    /// Whether this is the active slide.
    let isActive: Bool
    /// Jumps to this slide.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Capsule()
                .fill(isActive ? Theme.accent : Theme.ink.opacity(inactiveOpacity))
                .frame(width: isActive ? HeroTiming.activeDotWidth : HeroTiming.dotSize, height: HeroTiming.dotSize)
                .accentGlow(isActive)
                .padding(ShellLayout.Hero.dotHitPadding)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
    }

    private var inactiveOpacity: Double {
        isHovered ? HeroTiming.dotHoverOpacity : HeroTiming.dotOpacity
    }
}

#Preview {
    AppearancePreviewPair {
        HStack {
            CarouselDot(isActive: true) {}
            CarouselDot(isActive: false) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
