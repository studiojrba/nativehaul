import SwiftUI

/// The recurring eyebrow label (spec §2.7): Geist 500, uppercase, tracked 0.20em, `ink-mute`.
struct Eyebrow: View {
    /// The text (shown uppercased).
    let text: String
    /// Point size: ``TypeStyle/Eyebrow/size`` on desktop, ``TypeStyle/Eyebrow/heroSize`` on the hero,
    /// ``TypeStyle/Eyebrow/couchSize`` in couch mode.
    var size: CGFloat = TypeStyle.Eyebrow.size

    /// Creates an eyebrow.
    init(_ text: String, size: CGFloat = TypeStyle.Eyebrow.size) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text.uppercased())
            .font(Typeface.sans(size, weight: .medium))
            .tracking(TypeStyle.tracking(em: TypeStyle.Eyebrow.trackingEm, size: size))
            .foregroundStyle(Theme.inkMute)
            .accessibilityLabel(text)
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Eyebrow("Continue playing")
            Eyebrow("Jump back in", size: TypeStyle.Eyebrow.heroSize)
            Eyebrow("Couch", size: TypeStyle.Eyebrow.couchSize)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
