@testable import nativehaul
import Testing

/// Spec §4.4 reveal timing (hard requirements): 450ms first, dots 520 + min(500, length × 6)ms, 16ms a character,
/// +140ms after `.` or `?`, +80ms after `,`, 260ms between messages, actions only after the last message.
struct TypingScheduleTests {
    private static let tolerance = 0.000_001
    private static let longLength = 200
    private static let shortLength = 3

    @Test func dotsLastLongerForLongerMessagesUpToTheCap() {
        #expect(abs(TypingTiming.dotsDuration(length: Self.shortLength) - (0.52 + 0.018)) < Self.tolerance)
        #expect(abs(TypingTiming.dotsDuration(length: Self.longLength) - (0.52 + 0.5)) < Self.tolerance)
    }

    @Test func punctuationPausesTheReveal() {
        #expect(TypingTiming.delay(after: "a") == 0.016)
        #expect(abs(TypingTiming.delay(after: ".") - 0.156) < Self.tolerance)
        #expect(abs(TypingTiming.delay(after: "?") - 0.156) < Self.tolerance)
        #expect(abs(TypingTiming.delay(after: ",") - 0.096) < Self.tolerance)
    }

    @Test func oneMessageRunsDotsThenEachCharacterThenSendsThenReady() {
        let steps = TypingSchedule.steps(for: ["Hi."])
        #expect(steps.map(\.event) == [
            .dots(index: 0), .reveal(index: 0, count: 1), .reveal(index: 0, count: 2), .reveal(index: 0, count: 3),
            .send(index: 0), .ready,
        ])
        let delays = steps.map(\.delay)
        let expected = [0.45, 0.538, 0.016, 0.016, 0.156, 0.26]
        #expect(zip(delays, expected).allSatisfy { abs($0 - $1) < Self.tolerance })
    }

    @Test func laterMessagesWait260msAndActionsComeLast() {
        let steps = TypingSchedule.steps(for: ["A", "B"])
        let secondDots = steps.first { $0.event == .dots(index: 1) }
        #expect(secondDots?.delay == TypingTiming.betweenMessages)
        #expect(steps.last?.event == .ready)
        #expect(steps.filter {
            if case .send = $0.event {
                true
            } else {
                false
            }
        }.count == 2)
    }

    @Test func theWelcomeTakesAFewSecondsNotAMinute() {
        let duration = TypingSchedule.duration(of: OnboardingScript.welcome)
        #expect(duration > 3)
        // 0.1.1 adds the trust beat (note 8), so the welcome runs a little longer; still seconds, not a minute.
        #expect(duration < 12)
    }
}
