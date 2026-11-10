import SwiftUI

/// After the tour is exited: a quiet pill to pick it up where it left off, or put it away for good. Nothing nags.
struct GuideResumePill: View {
    /// The tour.
    let guide: OnboardingGuide

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button("Continue the tour", systemImage: "pawprint.fill") { guide.resume() }
                .buttonStyle(.borderless)
            Button("No thanks", systemImage: "xmark") { guide.dismissForGood() }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Put the tour away. It's always in Settings → General.")
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .surfaceCard(cornerRadius: DesignTokens.Radius.lg)
    }
}

#Preview {
    GuideResumePill(guide: OnboardingGuide(store: InMemoryOnboardingStore(progress: .paused(.builds))))
        .padding(DesignTokens.Spacing.xl)
}
