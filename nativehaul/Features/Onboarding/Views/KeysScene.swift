import SwiftUI

/// The keys scene (spec §3.6 "Keys"): a drop zone with a floating prod.keys card. Dropping the user's own file here
/// places it, like the picker does. The help variant adds a neutral steps card — it never names a tool or hints at
/// where the file comes from beyond "your own console".
struct KeysScene: View {
    /// The explainer variant.
    let isHelp: Bool
    /// Whether the file is already here (detected).
    let isFound: Bool
    /// A file was dropped.
    let drop: (URL) -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(spacing: ShellLayout.OnboardingScenes.stepsTop) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: KitMetrics.Radius.sheet, style: .continuous)
                    .fill(Theme.surface.opacity(ShellLayout.OnboardingScenes.keysFill))
                RoundedRectangle(cornerRadius: KitMetrics.Radius.sheet, style: .continuous)
                    .strokeBorder(
                        Theme.ink.opacity(isTargeted ? 0 : ShellLayout.OnboardingScenes.keysDashOpacity),
                        style: StrokeStyle(
                            lineWidth: ShellLayout.OnboardingScenes.dashWidth,
                            dash: ShellLayout.OnboardingScenes.dash
                        )
                    )
                    .accentOutline(
                        isTargeted,
                        in: RoundedRectangle(cornerRadius: KitMetrics.Radius.sheet, style: .continuous),
                        opacity: ShellLayout.OnboardingScenes.dropTargetOpacity
                    )
                fileCard.floatIdle().frame(maxHeight: .infinity)
                Text(caption)
                    .font(Typeface.sans(TypeStyle.Size.body))
                    .foregroundStyle(Theme.inkMute)
                    .padding(.bottom, ShellLayout.OnboardingScenes.captionBottom)
            }
            .aspectRatio(ShellLayout.OnboardingScenes.keysAspect, contentMode: .fit)
            .dropDestination(for: URL.self) { urls, _ in
                guard let url = urls.first, !isFound else { return false }
                drop(url)
                return true
            } isTargeted: { isTargeted = $0 }
            if isHelp {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    ForEach(OnboardingScript.keysSteps, id: \.self) { Text($0) }
                }
                .font(Typeface.sans(TypeStyle.Size.body))
                .foregroundStyle(Theme.inkSoft)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(ShellLayout.OnboardingScenes.stepsPadding)
                .background(
                    RoundedRectangle(cornerRadius: ShellLayout.OnboardingScenes.stepsRadius, style: .continuous)
                        .fill(Theme.surface.opacity(ShellLayout.OnboardingScenes.shelfOpacity))
                )
                .elevation(.small)
                .riseIn()
            }
        }
        .frame(maxWidth: ShellLayout.OnboardingScenes.keysMaxWidth)
    }

    private var caption: String {
        if isFound {
            return "Already on this Mac"
        }
        return isHelp ? "Drop it here whenever you’re ready" : "Drop the file here"
    }

    private var fileCard: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: KitMetrics.Radius.card, style: .continuous).fill(Theme.cream)
            Image(systemName: isFound ? "checkmark.seal" : "key")
                .font(.system(size: ShellLayout.OnboardingScenes.fileIcon))
                .foregroundStyle(Theme.ink)
                .frame(maxHeight: .infinity)
            Text("prod.keys")
                .font(.system(size: TypeStyle.Size.caption, design: .monospaced))
                .foregroundStyle(Theme.ink)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .overlay(alignment: .topTrailing) {
            UnevenRoundedRectangle(
                bottomLeadingRadius: KitMetrics.Radius.bar,
                topTrailingRadius: KitMetrics.Radius.card
            )
            .fill(Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity))
            .frame(width: ShellLayout.OnboardingScenes.fileFold, height: ShellLayout.OnboardingScenes.fileFold)
        }
        .frame(width: ShellLayout.OnboardingScenes.fileCard.width, height: ShellLayout.OnboardingScenes.fileCard.height)
        .elevation(.large)
        .rotationEffect(.degrees(ShellLayout.OnboardingScenes.fileTilt))
    }
}

#Preview {
    AppearancePreviewPair {
        KeysScene(isHelp: true, isFound: false) { _ in }.padding(DesignTokens.Spacing.xl)
    }
}
