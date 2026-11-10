import SwiftUI

/// Retriever talking (ADR 0040): a frosted bubble with short lines that appear one at a time, then the step's action.
/// Skip and Exit are always there; nothing in the tour is required.
struct GuideBubble: View {
    /// The tour.
    let guide: OnboardingGuide
    /// The step being shown.
    let step: GuideStep
    /// The step's main action (choosing folders, say); `nil` just moves on.
    var primaryAction: (() -> Void)?
    @State private var shownLines = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.guideTypesInstantly) private var typesInstantly

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: "pawprint.fill")
                .font(DesignTokens.Typography.title)
                .foregroundStyle(Theme.onAccent)
                .frame(width: DesignTokens.Guide.avatarSize, height: DesignTokens.Guide.avatarSize)
                .background(Theme.playGradient, in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                ForEach(Array(step.lines.prefix(visibleLines).enumerated()), id: \.offset) { index, line in
                    TypingText(text: line) { lineFinished(index) }
                }
                actions.padding(.top, DesignTokens.Spacing.xs)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: DesignTokens.Guide.bubbleMaxWidth, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                        .fill(Theme.surface.opacity(DesignTokens.Light.frostTintOpacity))
                }
                .shadow(
                    color: Theme.panelShadow,
                    radius: DesignTokens.FloatingRail.shadowRadius,
                    y: DesignTokens.FloatingRail.shadowOffset
                )
        }
        .id(step)
        .onChange(of: step) { shownLines = 1 }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Retriever's tour")
    }

    private var visibleLines: Int {
        reduceMotion || typesInstantly ? step.lines.count : shownLines
    }

    private var actions: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button(step.primaryTitle) {
                if let primaryAction {
                    primaryAction()
                } else {
                    guide.advance()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Theme.accent)
            .keyboardShortcut(.defaultAction)
            if step.next != nil {
                Button("Skip this step") { guide.skipStep() }
                    .buttonStyle(.borderless)
            }
            Spacer(minLength: DesignTokens.Spacing.none)
            Button("Exit tour", systemImage: "xmark") { guide.exit() }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Exit the tour. You can pick it up again later.")
        }
    }

    private func lineFinished(_ index: Int) {
        guard index + 1 == shownLines, shownLines < step.lines.count else { return }
        Task {
            try? await Task.sleep(for: .seconds(TypingSchedule.pauseAfterLine))
            shownLines += 1
        }
    }
}

#Preview {
    GuideBubble(guide: OnboardingGuide(store: InMemoryOnboardingStore(progress: .active(.welcome))), step: .welcome)
        .padding(DesignTokens.Spacing.xl)
        .background(Theme.canvas)
}
