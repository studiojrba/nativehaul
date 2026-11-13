@testable import nativehaul

/// Snapshots the typist at every wait (a test clock): the texts on screen and the last bubble's state.
@MainActor
final class TypingRecorder {
    /// The typist under test.
    weak var typist: ChatTypist?
    /// Texts at each wait.
    private(set) var texts: [[String]] = []
    /// The last bubble's state at each wait, without repeats (`.sent` before any bubble).
    private(set) var states: [BubbleProgress] = []

    /// Records one moment.
    func snapshot() {
        guard let typist else { return }
        texts.append(typist.messages.map(\.text))
        let state = typist.messages.last.map(typist.progress(of:)) ?? .sent
        if states.last != state {
            states.append(state)
        }
    }
}
