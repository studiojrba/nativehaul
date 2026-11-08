import Foundation

/// How Retriever starts a bottle's Windows Steam through CrossOver.
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
        tool("wine")
    }

    /// CrossOver's bottle manager (`cxbottle`) inside the app bundle.
    var cxbottleExecutablePath: String {
        tool("cxbottle")
    }

    /// Arguments that start `steamExe` in `bottle` and ask Steam to launch `appID`.
    func arguments(bottle: String, steamExe: String, appID: Int) -> [String] {
        runArguments(bottle: bottle, windowsExecutable: steamExe, arguments: ["-applaunch", String(appID)])
    }

    /// Arguments that run any Windows program in `bottle` through `wine`.
    func runArguments(bottle: String, windowsExecutable: String, arguments: [String] = []) -> [String] {
        ["--bottle", bottle, "--cx-app", windowsExecutable] + arguments
    }

    /// Arguments that create `bottle` from a template with `cxbottle`.
    func createBottleArguments(bottle: String, template: BottleTemplate, description: String) -> [String] {
        ["--bottle", bottle, "--create", "--template", template.cxbottleTemplate, "--description", description]
    }

    /// Arguments that clone `source` into a new bottle `bottle` with `cxbottle` (unverified against a live CrossOver).
    func cloneBottleArguments(bottle: String, source: String) -> [String] {
        ["--bottle", bottle, "--clone", source]
    }

    /// Arguments that set a bottle's Windows version through `winecfg` (unverified against a live CrossOver).
    func setWindowsVersionArguments(bottle: String, template: BottleTemplate) -> [String] {
        runArguments(bottle: bottle, windowsExecutable: "winecfg.exe", arguments: ["-v", template.rawValue])
    }

    private func tool(_ name: String) -> String {
        (crossOverAppPath as NSString).appendingPathComponent("Contents/SharedSupport/CrossOver/bin/\(name)")
    }
}
