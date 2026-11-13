@testable import nativehaul
import Testing

/// Spec §4.4: one bubble per message for its whole life, created with its full text; typing only changes how much
/// is visible.
@MainActor
struct ChatTypistTests {
    @Test func eachMessageIsAddedOnceWithItsFullTextAndMovesDotsRevealingSent() async {
        let recorder = TypingRecorder()
        let typist = ChatTypist { _ in await recorder.snapshot() }
        recorder.typist = typist
        #expect(await typist.type(["Hey."]))
        #expect(recorder.texts.dropFirst().allSatisfy { $0 == ["Hey."] })
        #expect(recorder.states == [
            .sent, .dots, .revealing(1), .revealing(2), .revealing(3), .revealing(4), .sent,
        ])
        #expect(typist.messages.map(\.text) == ["Hey."])
    }

    @Test func instantRevealShowsEverythingAtOnce() async {
        let typist = ChatTypist { _ in Issue.record("no waiting under Reduce Motion") }
        #expect(await typist.type(OnboardingScript.welcome, instantly: true))
        #expect(typist.messages.map(\.text) == OnboardingScript.welcome)
        #expect(typist.messages.allSatisfy { typist.progress(of: $0) == .sent })
    }

    @Test func repliesAreTheUsersAndStoppingEndsTyping() async {
        let typist = ChatTypist { _ in }
        typist.appendReply("Sure")
        #expect(typist.messages.last?.sender == .user)
        typist.stop()
        #expect(await !(typist.type(["Ignored."])))
        #expect(typist.messages.count == 1)
    }

    @Test func identitiesNeverRepeat() async {
        let typist = ChatTypist { _ in }
        _ = await typist.type(["One.", "Two."])
        typist.appendReply("Three")
        #expect(Set(typist.messages.map(\.id)).count == typist.messages.count)
    }
}
