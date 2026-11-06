import Foundation

/// How Playrite starts a bottle's Windows Steam through CrossOver.
///
/// Unverified against a live CrossOver install: the wine path and arguments follow CrossOver's documented
/// command-line usage (`wine --bottle <name> --cx-app <exe> …`) and are kept here so they can be adjusted in one place.
struct CrossOverLaunchConfiguration: Equatable, Sendable {
    /// Standard install in /Applications.
    static let standard = CrossOverLaunchConfiguration(crossOverAppPath: "/Applications/CrossOver.app")

    /// CrossOver.app location.
    var crossOverAppPath: String

    /// CrossOver's wine launcher inside the app bundle.
    var wineExecutablePath: String {
        (crossOverAppPath as NSString).appendingPathComponent("Contents/SharedSupport/CrossOver/bin/wine")
    }

    /// Arguments that start `steamExe` in `bottle` and ask Steam to launch `appID`.
    func arguments(bottle: String, steamExe: String, appID: Int) -> [String] {
        ["--bottle", bottle, "--cx-app", steamExe, "-applaunch", String(appID)]
    }
}
