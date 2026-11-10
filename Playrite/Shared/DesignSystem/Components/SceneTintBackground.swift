import SwiftUI

/// The window background (ADR 0040): the cream canvas with the current scene's pastel washed down from the top.
struct SceneTintBackground: View {
    /// Art the scene is about, or `nil` for plain cream.
    let artPath: String?
    @Environment(\.designIntensity) private var intensity
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Theme.canvas
            .overlay {
                if let tint = ArtworkTint.nsColor(forImageAt: artPath) {
                    let energy = EnergyLevel.of(intensity)
                    let pastel = SceneTint.pastel(from: tint, saturation: energy.pastelSaturation)
                    LinearGradient(
                        stops: [
                            .init(color: Color(nsColor: pastel).opacity(energy.ambientOpacity), location: 0),
                            .init(color: Theme.canvas, location: DesignTokens.Light.tintReach),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .transition(.opacity)
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: DesignTokens.Light.tintChangeSeconds), value: artPath)
            .ignoresSafeArea()
    }
}

#Preview {
    SceneTintBackground(artPath: nil)
}
