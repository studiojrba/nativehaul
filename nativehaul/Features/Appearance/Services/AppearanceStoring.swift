/// Loads and saves the ``AppearancePreference``. Protocol-first (ADR 0002).
@MainActor
protocol AppearanceStoring: AnyObject {
    /// The saved choice, or `nil` when the user never chose (first launch).
    func load() -> AppearancePreference?
    /// Saves the choice.
    func save(_ preference: AppearancePreference)
}
