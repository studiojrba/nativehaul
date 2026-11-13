import SwiftUI

/// Three 6pt dots (`ink` 40%) bouncing with 120ms staggers (spec §4.4), shown inside the already-sized bubble. Still
/// under Reduce Motion.
struct TypingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            HStack(spacing: ShellLayout.Onboarding.dotsGap) {
                ForEach(0 ..< Self.count, id: \.self) { index in
                    Circle()
                        .fill(Theme.ink.opacity(TypingTiming.dotOpacity))
                        .frame(width: TypingTiming.dotSize, height: TypingTiming.dotSize)
                        .offset(y: reduceMotion ? 0 : bounce(at: timeline.date, index: index))
                }
            }
            .frame(height: ShellLayout.Onboarding.dotsRowHeight)
        }
        .accessibilityLabel("nativehaul is typing")
    }

    /// A dot's height in its bounce: up for the first half of each second, resting for the second.
    private func bounce(at date: Date, index: Int) -> CGFloat {
        let time = date.timeIntervalSinceReferenceDate - Double(index) * TypingTiming.dotStagger
        let phase = time.truncatingRemainder(dividingBy: Self.period) / Self.period
        let lift = phase < Self.half ? sin(phase / Self.half * .pi) : 0
        return -ShellLayout.Onboarding.dotsBounce * lift
    }

    private static let count = 3
    private static let period: Double = 1
    private static let half: Double = 0.5
}

#Preview {
    AppearancePreviewPair {
        TypingDots().padding(DesignTokens.Spacing.xl)
    }
}
