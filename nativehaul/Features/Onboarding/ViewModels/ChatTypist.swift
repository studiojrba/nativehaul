import Foundation
import Observation

/// Types the conversation (spec §4.4): each message is added once, at its final size, then moves through dots →
/// revealing → sent on the schedule in ``TypingSchedule``. The text never changes — only how much of it is visible.
/// Under Reduce Motion everything appears at once.
@MainActor
@Observable
final class ChatTypist {
    /// Waits this many seconds (injected so tests run instantly).
    typealias Sleep = @Sendable (Double) async -> Void

    /// Every bubble so far, oldest first.
    private(set) var messages: [ChatMessage] = []
    /// The message being typed.
    private(set) var activeID: Int?
    /// Characters revealed in the active message; `nil` while its dots show.
    private(set) var revealedCount: Int?

    @ObservationIgnored private var nextID = 0
    @ObservationIgnored private var isStopped = false
    @ObservationIgnored private let sleep: Sleep

    /// Creates the typist.
    init(sleep: @escaping Sleep = ChatTypist.realSleep) {
        self.sleep = sleep
    }

    /// The state of `message`'s bubble.
    func progress(of message: ChatMessage) -> BubbleProgress {
        guard message.id == activeID else { return .sent }
        return revealedCount.map(BubbleProgress.revealing) ?? .dots
    }

    /// Types nativehaul's `texts` one after another. Returns `false` if stopped part-way.
    func type(_ texts: [String], instantly: Bool = false) async -> Bool {
        guard !isStopped else { return false }
        if instantly {
            texts.forEach { append($0, from: .app) }
            return true
        }
        var ids: [Int] = []
        for step in TypingSchedule.steps(for: texts) {
            await sleep(step.delay)
            guard !isStopped else { return false }
            switch step.event {
            case .dots:
                ids.append(append(texts[ids.count], from: .app))
                activeID = ids.last
                revealedCount = nil
            case let .reveal(_, count):
                revealedCount = count
            case .send:
                activeID = nil
                revealedCount = nil
            case .ready:
                return true
            }
        }
        return true
    }

    /// Adds the user's answer as a sent bubble.
    func appendReply(_ text: String) {
        append(text, from: .user)
    }

    /// Stops typing (the tour is over); the current message is shown whole.
    func stop() {
        isStopped = true
        activeID = nil
        revealedCount = nil
    }

    @discardableResult
    private func append(_ text: String, from sender: ChatMessage.Sender) -> Int {
        let id = nextID
        nextID += 1
        messages.append(ChatMessage(id: id, sender: sender, text: text))
        return id
    }

    /// The real clock.
    nonisolated static func realSleep(_ seconds: Double) async {
        try? await Task.sleep(for: .seconds(seconds))
    }
}
