/// Recording ``UISoundPlaying`` for previews and tests.
@MainActor
final class MockUISoundPlayer: UISoundPlaying {
    /// Every sound played, in order.
    private(set) var played: [UISound] = []

    /// Creates the mock.
    init() {}

    func play(_ sound: UISound) {
        played.append(sound)
    }
}
