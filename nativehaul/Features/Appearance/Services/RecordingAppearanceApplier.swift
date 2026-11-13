/// ``AppearanceApplying`` for previews and tests: records what was applied.
@MainActor
final class RecordingAppearanceApplier: AppearanceApplying {
    /// Every applied preference, in order.
    private(set) var applied: [AppearancePreference] = []

    /// Creates the recorder.
    init() {}

    func apply(_ preference: AppearancePreference) {
        applied.append(preference)
    }
}
