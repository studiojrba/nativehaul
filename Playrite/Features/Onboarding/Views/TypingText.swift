import SwiftUI

/// One line Retriever "says" (ADR 0040): typed out with a visible caret while it speaks. Under Reduce Motion the line
/// appears whole, with no caret.
struct TypingText: View {
    /// The caret alternates between two phases: shown, hidden.
    private static let caretPhases = 2
    /// The line.
    let text: String
    /// Called once the line is fully shown.
    var onFinished: () -> Void = {}
    @State private var start = Date()
    @State private var isFinished = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.guideTypesInstantly) private var typesInstantly

    var body: some View {
        Group {
            if reduceMotion || typesInstantly || isFinished {
                Text(text)
            } else {
                TimelineView(.animation) { context in
                    let elapsed = context.date.timeIntervalSince(start)
                    let count = TypingSchedule.visibleCount(elapsed: elapsed, length: text.count)
                    let caretOn = Int(elapsed / DesignTokens.Guide.caretSeconds).isMultiple(of: Self.caretPhases)
                    Text(String(text.prefix(count)))
                        + Text(caretOn ? "▍" : " ").foregroundStyle(Theme.accent)
                }
            }
        }
        .font(DesignTokens.DetailColumn.lead)
        .foregroundStyle(Theme.primaryText)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel(text)
        .task(id: text) {
            start = Date()
            isFinished = false
            if !(reduceMotion || typesInstantly) {
                try? await Task.sleep(for: .seconds(TypingSchedule.duration(length: text.count)))
            }
            guard !Task.isCancelled else { return }
            isFinished = true
            onFinished()
        }
    }
}

#Preview {
    TypingText(text: "Hi! I'm Retriever.")
        .padding(DesignTokens.Spacing.lg)
}
