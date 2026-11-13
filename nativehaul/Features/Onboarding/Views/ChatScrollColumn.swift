import SwiftUI

/// The conversation's own scroll region (spec §4.4): bottom-anchored like a messaging app, starting at the bottom with
/// no animation, smoothly following only when a new bubble arrives (typing never changes its height). Scrolling up
/// stops following at once and nothing ever yanks the reader back; following resumes within 64pt of the bottom or when
/// they answer. Mouse drag-to-scroll works with a 5pt threshold and the grabbing cursor. The top fades out.
struct ChatScrollColumn: View {
    /// The conversation.
    let typist: ChatTypist

    private static let sides: CGFloat = 2

    @State private var position = ScrollPosition(edge: .bottom)
    @State private var follow = ChatFollow()
    @State private var metrics = ChatScrollMetrics()
    @State private var isReaderScrolling = false
    @State private var dragStartOffset: CGFloat?
    @State private var width: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(spacing: ShellLayout.Onboarding.bubbleGap) {
                ForEach(typist.messages) { message in
                    ChatBubble(
                        message: message,
                        progress: typist.progress(of: message),
                        maxWidth: max(0, width - ShellLayout.Onboarding.chatInset * Self.sides)
                            * ShellLayout.Onboarding.bubbleMaxShare
                    )
                }
            }
            .padding(ShellLayout.Onboarding.chatInset)
            .frame(minHeight: metrics.containerHeight, alignment: .bottom)
        }
        .scrollIndicators(.never)
        .scrollPosition($position)
        .defaultScrollAnchor(.bottom)
        .onScrollGeometryChange(for: ChatScrollMetrics.self) { geometry in
            ChatScrollMetrics(
                offset: geometry.contentOffset.y,
                distanceFromBottom: max(
                    0,
                    geometry.contentSize.height - geometry.contentOffset.y
                        - geometry.containerSize.height
                ),
                containerHeight: geometry.containerSize.height
            )
        } action: { old, new in
            metrics = new
            if isReaderScrolling {
                follow.readerScrolled(from: old.offset, to: new.offset, distanceFromBottom: new.distanceFromBottom)
            }
            if old.containerHeight != new.containerHeight, follow.isFollowing {
                position.scrollTo(edge: .bottom)
            }
        }
        .onScrollPhaseChange { _, phase in
            isReaderScrolling = phase == .interacting || phase == .decelerating || phase == .tracking
        }
        .onChange(of: typist.messages.count) {
            if typist.messages.last?.sender == .user {
                follow.answered()
            }
            guard follow.scrollsToNewBubble else { return }
            withAnimation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise)) {
                position.scrollTo(edge: .bottom)
            }
        }
        .simultaneousGesture(drag)
        .pointerStyle(dragStartOffset == nil ? nil : .grabActive)
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: ShellLayout.Onboarding.maskStop),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { width = $0 }
    }

    /// Mouse drag-to-scroll: past 5pt the chat follows the pointer; dragging down reads back.
    private var drag: some Gesture {
        DragGesture(minimumDistance: ShellLayout.Onboarding.dragThreshold)
            .onChanged { value in
                let start = dragStartOffset ?? metrics.offset
                dragStartOffset = start
                if value.translation.height > 0 {
                    follow.readerDraggedBack()
                }
                position.scrollTo(y: start - value.translation.height)
            }
            .onEnded { _ in
                if let start = dragStartOffset {
                    follow.readerScrolled(
                        from: start,
                        to: metrics.offset,
                        distanceFromBottom: metrics.distanceFromBottom
                    )
                }
                dragStartOffset = nil
            }
    }
}

#Preview {
    let typist = ChatTypist()
    ChatScrollColumn(typist: typist)
        .task { _ = await typist.type(OnboardingScript.welcome, instantly: true) }
        .frame(width: ShellLayout.Onboarding.chatMinWidth, height: ShellLayout.Onboarding.clusterMax)
        .background(Theme.paper)
}
