import CoreGraphics
import SwiftUI

extension DesignTokens {
    /// The game detail page's two zones and its 3D game case (ADR 0039).
    enum GameCase {
        /// Width of the sticky case panel.
        static let panelWidth: CGFloat = 360
        /// Case width in scene units. One proportion for every game: the shelf fiction of a physical box (a keep case,
        /// 135 × 190 × 14 mm), whatever the platform.
        static let width: CGFloat = 1.35
        /// Case height in scene units.
        static let height: CGFloat = 1.9
        /// Case depth (spine width) in scene units.
        static let depth: CGFloat = 0.14
        /// Rounding of the case's edges.
        static let chamfer: CGFloat = 0.03
        /// Width ÷ height of the front and back faces.
        static let faceAspect: CGFloat = width / height
        /// Width ÷ height of the spine.
        static let spineAspect: CGFloat = depth / height
        /// Pixel height of the generated face textures.
        static let texturePixels: CGFloat = 1400
        /// Turn the case rests at, so the spine shows a little (radians about the vertical axis).
        static let presentationYaw: Double = 0.42
        /// Tilt the case rests at (radians about the horizontal axis).
        static let presentationPitch: Double = 0.08
        /// Radians turned per point dragged.
        static let dragSensitivity: Double = 0.012
        /// Most a drag may tilt the case forward or back.
        static let pitchLimit: Double = 0.6
        /// How quickly a flick's spin dies away (share of speed kept per second).
        static let inertiaRetention: Double = 0.06
        /// Below this speed (radians a second) the case starts settling.
        static let settleSpeed: Double = 0.35
        /// How quickly the case eases back to its resting angle (per second).
        static let settleRate: Double = 5
        /// Idle sway either side of the resting angle (radians).
        static let idleSwayAmplitude: Double = 0.05
        /// Seconds per idle sway cycle.
        static let idleSwayPeriod: Double = 7
        /// Camera distance range for the zoom buttons.
        static let cameraNear: CGFloat = 3.2
        /// Farthest camera distance.
        static let cameraFar: CGFloat = 5.4
        /// Resting camera distance.
        static let cameraRest: CGFloat = 4.3
        /// Camera distance changed per zoom click.
        static let cameraStep: CGFloat = 0.55
        /// Frames per second for the case's motion.
        static let framesPerSecond: Double = 60
        /// Spine title size as a share of the spine's width in pixels.
        static let spineTitleShare: CGFloat = 0.5
        /// Inset of the spine title from the spine's ends, as a share of its length.
        static let spineTitleInset: CGFloat = 0.06
        /// Spine title line height as a multiple of its size.
        static let spineLineHeight: CGFloat = 1.3
        /// The spine title runs top to bottom.
        static let spineRotationDegrees: CGFloat = -90
        /// Camera field of view (degrees).
        static let fieldOfView: CGFloat = 30
        /// Seconds a zoom click takes.
        static let zoomSeconds: Double = 0.3
        /// Key light direction: from above (pitch) and to the left (yaw), radians.
        static let keyLightPitch: CGFloat = -0.5
        /// Key light yaw.
        static let keyLightYaw: CGFloat = -0.4
        /// Key light strength.
        static let keyLightIntensity: CGFloat = 900
        /// Fill (ambient) light strength.
        static let fillLightIntensity: CGFloat = 450
        /// How glossy the case's plastic is (0 = matte).
        static let gloss: CGFloat = 0.25
        /// How dark the case's plastic edges are relative to the art tint.
        static let edgeDarkening: CGFloat = 0.35
    }

    /// The detail page's right column (ADR 0039).
    enum DetailColumn {
        /// Lead (short description) size.
        static let leadSize: CGFloat = 21
        /// Lead font: the large subheading style.
        static let lead: Font = .system(size: leadSize, weight: .medium, design: .rounded)
        /// Longest short description shown at the top before it is cut at a sentence.
        static let shortLimit = 280
        /// Width of the specs table's label column.
        static let specLabelWidth: CGFloat = 140
        /// Height of the HLTB bar.
        static let barHeight: CGFloat = 10
        /// Width of a marker on the HLTB bar.
        static let markerWidth: CGFloat = 2
    }
}
