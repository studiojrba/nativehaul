import SwiftUI

extension EnvironmentValues {
    /// When true, the game case is drawn as a still image rendered offscreen instead of a live SceneKit view
    /// (ADR 0039). Offscreen renders can't capture a live Metal view; the still is the same scene.
    @Entry var gameCaseRendersStill = false
}
