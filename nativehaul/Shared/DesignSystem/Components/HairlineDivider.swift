import SwiftUI

/// A 1-pt hairline rule in ``Theme/hairline`` (ADR 0025), vertical or horizontal.
struct HairlineDivider: View {
    /// Which way the rule runs.
    var axis = Axis.horizontal

    var body: some View {
        switch axis {
        case .horizontal: Rectangle().fill(Theme.hairline).frame(height: DesignTokens.Stroke.hairline)
        case .vertical: Rectangle().fill(Theme.hairline).frame(width: DesignTokens.Stroke.hairline)
        }
    }
}

#Preview {
    HairlineDivider().padding(DesignTokens.Spacing.lg)
}
