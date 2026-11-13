import Foundation

/// The reveal timing (spec §4.4, hard requirements): the first message starts after 450ms; dots for
/// 520 + min(500, length × 6) ms; then a character every 16ms, pausing 140ms after `.` or `?` and 80ms after `,`;
/// 260ms between messages; the actions only after the last message sends (and its 260ms).
enum TypingSchedule {
    /// Every step for a beat's `messages`, in order.
    static func steps(for messages: [String]) -> [TypingStep] {
        var steps: [TypingStep] = []
        for (index, message) in messages.enumerated() {
            let characters = Array(message)
            let lead = index == 0 ? TypingTiming.firstDelay : TypingTiming.betweenMessages
            steps.append(TypingStep(delay: lead, event: .dots(index: index)))
            var wait = TypingTiming.dotsDuration(length: characters.count)
            for (offset, character) in characters.enumerated() {
                steps.append(TypingStep(delay: wait, event: .reveal(index: index, count: offset + 1)))
                wait = TypingTiming.delay(after: character)
            }
            steps.append(TypingStep(delay: wait, event: .send(index: index)))
        }
        steps.append(TypingStep(delay: messages.isEmpty ? 0 : TypingTiming.betweenMessages, event: .ready))
        return steps
    }

    /// How long a beat takes to type, in seconds.
    static func duration(of messages: [String]) -> Double {
        steps(for: messages).reduce(0) { $0 + $1.delay }
    }
}
