import SwiftUI

/// The build log's live caret: a lamp-coloured block blinking once a second (`steps(2)`).
struct BlinkingCaret: View {
    private static let blinkPhases = 2

    var body: some View {
        TimelineView(.periodic(from: .now, by: TypingTiming.caretPhase)) { timeline in
            let isOn = Int(timeline.date.timeIntervalSinceReferenceDate / TypingTiming.caretPhase)
                .isMultiple(of: Self.blinkPhases)
            Rectangle()
                .fill(Theme.lamp.opacity(ShellLayout.BuildLog.caretOpacity))
                .frame(width: ShellLayout.BuildLog.caretWidth, height: ShellLayout.BuildLog.lineSize)
                .opacity(isOn ? 1 : 0)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    BlinkingCaret().padding(DesignTokens.Spacing.lg).background(Theme.bezel)
}
