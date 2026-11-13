import Foundation

/// The couch-mode preferences chosen at the end of onboarding and in Settings → Couch mode (TV plan Q7, ADR 0057):
/// which mode nativehaul opens in, and whether the controller rumbles. Live: ``UserDefaultsModePreferenceStore``; mock:
/// ``InMemoryModePreferenceStore``. Couch mode reads these at launch.
@MainActor
protocol ModePreferenceStoring: AnyObject {
    /// What nativehaul shows when it starts (default ``AppMode/desktop``).
    var defaultMode: AppMode { get set }
    /// Whether the controller gives a little buzz on a pick (default on).
    var isRumbleEnabled: Bool { get set }
}
