/// Applies an appearance app-wide (AppKit's side: windows, menus, dynamic colours). Protocol-first so tests can
/// observe it without touching the real app.
@MainActor
protocol AppearanceApplying: AnyObject {
    /// Applies `preference` to the whole app.
    func apply(_ preference: AppearancePreference)
}
