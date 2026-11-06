import Foundation

/// Where a one-click install is. Every state is shown as-is; nothing is hidden behind a spinner.
enum BottleInstallStage: Equatable, Sendable {
    /// Checking CrossOver, the recipe and disk space.
    case checking
    /// `cxbottle --create` is running (golden bottle setup).
    case creatingBottle(name: String)
    /// Cloning the golden bottle into the game's own bottle.
    case cloningBottle(name: String)
    /// Writing the recipe's settings into the bottle.
    case applyingRecipe
    /// Downloading and running Steam's installer inside the bottle.
    case installingSteam
    /// Steam is open in the bottle; waiting for the user to sign in there themselves.
    case waitingForSignIn
    /// The golden bottle's Steam is signed in; games can now be installed with one click.
    case steamReady
    /// Asking the bottle's Steam to install the game.
    case startingDownload
    /// Steam's session didn't carry over to this clone; the user needs to sign in in this bottle's Steam window.
    case needsSignInInBottle(name: String)
    /// Steam is downloading. `fraction` is 0…1 once Steam reports sizes.
    case downloading(fraction: Double?)
    /// The game is installed in the bottle.
    case installed
    /// Stopped, with the reason.
    case failed(reason: String)

    /// Whether the install has stopped (successfully or not).
    var isFinished: Bool {
        switch self {
        case .installed, .failed, .steamReady: true
        default: false
        }
    }

    /// Plain description.
    var displayText: String {
        switch self {
        case .checking: "Checking…"
        case let .creatingBottle(name): "Creating bottle “\(name)”…"
        case let .cloningBottle(name): "Creating bottle “\(name)” from your signed-in Steam…"
        case .applyingRecipe: "Applying the game's settings…"
        case .installingSteam: "Installing Steam in the bottle…"
        case .waitingForSignIn: "Waiting for you to sign in to Steam"
        case let .needsSignInInBottle(name): "Steam needs a sign-in in “\(name)”"
        case .startingDownload: "Starting the download…"
        case let .downloading(fraction):
            fraction.map { "Downloading — \(Int(($0 * BottleInstallStage.percent).rounded()))%" } ?? "Downloading…"
        case .installed: "Installed"
        case .steamReady: "Steam is signed in and ready"
        case let .failed(reason): "Failed: \(reason)"
        }
    }

    private static let percent = 100.0
}
