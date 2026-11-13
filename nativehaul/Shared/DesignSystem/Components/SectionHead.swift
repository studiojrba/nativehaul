import SwiftUI

/// A 0.1.0 section heading (spec §3.1 `SectionHead`): eyebrow, then a 52pt display title at line height 0.95, with an
/// optional accessory on the right, bottom-aligned.
struct SectionHead<Accessory: View>: View {
    /// The eyebrow.
    let eyebrow: String
    /// The title.
    let title: String
    /// Right-aligned accessory.
    @ViewBuilder var accessory: () -> Accessory

    var body: some View {
        HStack(alignment: .bottom, spacing: KitMetrics.Spacing.roomy) {
            VStack(alignment: .leading, spacing: ShellLayout.SectionHead.titleTop) {
                Eyebrow(eyebrow)
                DisplayHeadline(lead: title)
            }
            Spacer(minLength: 0)
            accessory()
        }
    }
}

extension SectionHead where Accessory == EmptyView {
    /// A heading without an accessory.
    init(eyebrow: String, title: String) {
        self.init(eyebrow: eyebrow, title: title) { EmptyView() }
    }
}

#Preview {
    AppearancePreviewPair {
        SectionHead(eyebrow: "Continue playing", title: "Still on the go")
            .padding(DesignTokens.Spacing.xl)
    }
}
