import SwiftUI

/// One chat bubble, one view for the message's whole life (spec §4.4). The full text is laid out from the first frame,
/// so the bubble is created at its final size; typing only changes which characters ``BubbleRevealRenderer`` draws,
/// never the text, so nothing moves by a pixel — not while typing, not at the send moment. The dots sit inside the
/// sized bubble; the caret blinks outside the text flow. App bubbles are frost on the left with a bottom-left tail,
/// the user's are cream on the right with a bottom-right tail. It rises in once, on appear.
struct ChatBubble: View {
    /// The message.
    let message: ChatMessage
    /// Its state.
    let progress: BubbleProgress
    /// Split or page 1.
    var style = ChatBubbleStyle.split
    /// The widest the bubble may be.
    let maxWidth: CGFloat
    /// Skip the entrance (page 1's hidden size reservation).
    var isStill = false

    var body: some View {
        HStack(spacing: 0) {
            if message.sender == .user || style.isCentered {
                Spacer(minLength: 0)
            }
            bubble
            if message.sender == .app || style.isCentered {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: maxWidth)
        .frame(maxWidth: .infinity, alignment: alignment)
        .modifier(BubbleEntrance(isStill: isStill))
    }

    private var bubble: some View {
        TimelineView(.animation(minimumInterval: TypingTiming.caretPhase, paused: !isRevealing)) { timeline in
            text(caretOn: isCaretOn(at: timeline.date))
        }
        .padding(.horizontal, ShellLayout.Onboarding.bubbleHorizontal)
        .padding(.vertical, ShellLayout.Onboarding.bubbleVertical)
        .overlay(alignment: style.isCentered ? .top : .topLeading) {
            if progress == .dots {
                TypingDots()
                    .padding(.top, ShellLayout.Onboarding.bubbleVertical)
                    .padding(
                        .leading,
                        style.isCentered ? DesignTokens.Spacing.none : ShellLayout.Onboarding.bubbleHorizontal
                    )
            }
        }
        .background { background }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(progress == .sent ? message.text : "")
        .accessibilityHidden(progress != .sent)
    }

    private func text(caretOn: Bool) -> some View {
        revealedText
            .font(Typeface.sans(style.textSize))
            .lineSpacing(style.lineSpacing)
            .foregroundStyle(Theme.ink)
            .multilineTextAlignment(style.isCentered ? .center : .leading)
            .fixedSize(horizontal: false, vertical: true)
            .textRenderer(BubbleRevealRenderer(
                revealsAll: progress == .sent,
                showsCaret: caretOn,
                endsInSpace: endsInSpace
            ))
    }

    /// The whole text, the revealed prefix marked ``RevealedRun``. Same characters every frame.
    private var revealedText: Text {
        guard case let .revealing(count) = progress else {
            return Text(verbatim: message.text)
        }
        let split = message.text.index(message.text.startIndex, offsetBy: min(count, message.text.count))
        let shown = Text(verbatim: String(message.text[..<split])).customAttribute(RevealedRun())
        let hidden = Text(verbatim: String(message.text[split...]))
        return Text("\(shown)\(hidden)")
    }

    private var endsInSpace: Bool {
        guard case let .revealing(count) = progress, count > 0 else { return false }
        let index = message.text.index(message.text.startIndex, offsetBy: min(count, message.text.count) - 1)
        return message.text[index].isWhitespace
    }

    private static let blinkPhases = 2

    private var isRevealing: Bool {
        if case .revealing = progress {
            return true
        }
        return false
    }

    private func isCaretOn(at date: Date) -> Bool {
        guard isRevealing else { return false }
        return Int(date.timeIntervalSinceReferenceDate / TypingTiming.caretPhase).isMultiple(of: Self.blinkPhases)
    }

    private var alignment: Alignment {
        if style.isCentered {
            return .center
        }
        return message.sender == .user ? .trailing : .leading
    }

    private var shape: UnevenRoundedRectangle {
        let radius = ShellLayout.Onboarding.bubbleRadius
        let tail = ShellLayout.Onboarding.bubbleTail
        return UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: message.sender == .app ? tail : radius,
            bottomTrailingRadius: message.sender == .user ? tail : radius,
            topTrailingRadius: radius,
            style: .continuous
        )
    }

    @ViewBuilder private var background: some View {
        if message.sender == .user {
            shape.fill(Theme.cream)
        } else {
            Color.clear.frostedGlass(in: shape).elevation(.small)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: ShellLayout.Onboarding.bubbleGap) {
            ChatBubble(
                message: ChatMessage(id: 0, sender: .app, text: "First up: where do your games live?"),
                progress: .sent,
                maxWidth: ShellLayout.Onboarding.chatMinWidth
            )
            ChatBubble(
                message: ChatMessage(id: 1, sender: .app, text: "Point me at the folder and I’ll have a look."),
                progress: .revealing("Point me at the".count),
                maxWidth: ShellLayout.Onboarding.chatMinWidth
            )
            ChatBubble(
                message: ChatMessage(id: 2, sender: .app, text: "Typing…"),
                progress: .dots,
                maxWidth: ShellLayout.Onboarding.chatMinWidth
            )
            ChatBubble(
                message: ChatMessage(id: 3, sender: .user, text: "This one: ~/Games"),
                progress: .sent,
                maxWidth: ShellLayout.Onboarding.chatMinWidth
            )
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
