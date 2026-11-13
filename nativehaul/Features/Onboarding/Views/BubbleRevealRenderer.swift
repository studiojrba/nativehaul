import SwiftUI

/// Draws a bubble's text as typing reveals it (spec §4.4): the full text is laid out from the first frame and only the
/// runs marked ``RevealedRun`` are drawn, so the bubble's size and line breaks never move. The 2pt accent caret is
/// drawn
/// here too — outside the text flow — just after the last revealed character (64% of the line tall, dropped 18%), or at
/// the start of the next line when the reveal stopped on a space that wrapped.
struct BubbleRevealRenderer: TextRenderer {
    /// Draw every run (the message is sent).
    var revealsAll: Bool
    /// Draw the caret (blink phase on, still typing).
    var showsCaret: Bool
    /// The revealed part ends with whitespace.
    var endsInSpace: Bool

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var caretLine: (index: Int, rect: CGRect)?
        var firstHidden: (index: Int, rect: CGRect)?
        for (index, line) in layout.enumerated() {
            for run in line {
                let rect = run.typographicBounds.rect
                if revealsAll || run[RevealedRun.self] != nil {
                    context.draw(run)
                    caretLine = (index, rect)
                } else if firstHidden == nil {
                    firstHidden = (index, rect)
                }
            }
        }
        guard showsCaret, !revealsAll else { return }
        context.fill(Path(caretRect(after: caretLine, next: firstHidden)), with: .color(Theme.accent))
    }

    private func caretRect(after revealed: (index: Int, rect: CGRect)?, next: (index: Int, rect: CGRect)?) -> CGRect {
        let wrapsToNext = revealed.map { last in endsInSpace && (next.map { $0.index > last.index } ?? false) } ?? true
        if wrapsToNext, let next {
            return caret(x: next.rect.minX, line: next.rect)
        }
        guard let revealed else { return .zero }
        return caret(x: revealed.rect.maxX, line: revealed.rect)
    }

    private func caret(x: CGFloat, line: CGRect) -> CGRect {
        CGRect(
            x: x,
            y: line.minY + line.height * TypingTiming.caretDropShare,
            width: TypingTiming.caretWidth,
            height: line.height * TypingTiming.caretHeightShare
        )
    }
}
