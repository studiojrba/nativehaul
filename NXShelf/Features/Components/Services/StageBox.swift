import Foundation

/// Holds the last stage reported during an unattended update.
@MainActor
final class StageBox {
    /// Last stage.
    var stage: ComponentInstallStage?
}
