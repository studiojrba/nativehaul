import Foundation

/// What a couch input asks the app to do, beyond moving focus (``CouchNavigator``). The view model carries these out;
/// the navigator itself never touches the UI or a service.
enum CouchEffect: Equatable, Sendable {
    /// Play an interface sound.
    case sound(UISound)
    /// The previous hero game.
    case previousHero
    /// The next hero game.
    case nextHero
    /// Play the hero's game.
    case playHero
    /// Open the hero game's Detail.
    case openHeroDetails
    /// Play a game.
    case play(UUID)
    /// Open a game's Detail.
    case openDetails(UUID)
    /// Show a toast.
    case toast(CouchToast)
    /// Leave couch for the desktop.
    case exitToDesktop
    /// The Builds list's focus moved to a job.
    case selectBuild(Int)
    /// A on a Builds job: open its game.
    case openBuild(Int)
    /// Change a Settings row.
    case setting(CouchSettingsRow, CouchSettingChange)
    /// Detail's favourite button.
    case toggleFavorite
    /// Resume the running game.
    case resumeGame
    /// Close the running game gracefully.
    case closeGame
    /// Force quit the running game.
    case forceQuitGame
    /// Give a closing game more time.
    case keepWaiting
    /// The launch phase was dismissed (the safety valve if a game never comes forward).
    case dismissLaunch
}
