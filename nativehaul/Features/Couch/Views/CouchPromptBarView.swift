import SwiftUI

/// The contextual prompt bar (spec §3.7): a frost pill inset 48pt from each side and 32pt from the bottom, what the
/// focused thing does on the left and the way out on the right. Hidden when empty.
struct CouchPromptBarView: View {
    /// The prompts.
    let bar: CouchPromptBar
    /// Which controller's glyphs to draw.
    let family: ControllerFamily
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.PromptBar

    var body: some View {
        if !bar.isEmpty {
            HStack(spacing: scale(Metrics.gap)) {
                group(bar.leading)
                Spacer(minLength: 0)
                group(bar.trailing)
            }
            .padding(.horizontal, scale(Metrics.horizontal))
            .padding(.vertical, scale(Metrics.vertical))
            .frostedGlass()
            .elevation(.regular)
            .padding(.horizontal, scale(Metrics.side))
            .padding(.bottom, scale(Metrics.bottom))
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private func group(_ prompts: [CouchPrompt]) -> some View {
        HStack(spacing: scale(Metrics.gap)) {
            ForEach(prompts) { CouchPromptView(prompt: $0, family: family, scale: scale) }
        }
    }
}

#Preview {
    let scale = CouchScale(size: CouchLayout.previewScreen)
    let state = CouchFocusState()
    AppearancePreviewPair {
        CouchPromptBarView(
            bar: CouchPrompts.bar(for: state, context: CouchContext(heroCount: 3)),
            family: .nintendo,
            scale: scale
        )
        .frame(width: CouchLayout.previewHalf.width, height: CouchLayout.previewHalf.height)
    }
}
