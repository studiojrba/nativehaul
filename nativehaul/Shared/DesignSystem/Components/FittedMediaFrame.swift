import SwiftUI

/// A frame that takes the current slide's own shape (media pass, ADR 0038). It spans the available width, sizes its
/// content with ``MediaFit``, and centres it, so the whole image is always visible: never cropped, never
/// letterboxed. When the aspect changes (the next slide), the frame follows it with a short resize.
struct FittedMediaFrame<Content: View>: View {
    /// Width ÷ height of what is showing now.
    let aspect: CGFloat
    /// Tallest the frame may grow.
    let maxHeight: CGFloat
    /// The media, sized to the fitted frame.
    @ViewBuilder let content: Content
    @State private var availableWidth: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let size = MediaFit.size(aspect: aspect, availableWidth: availableWidth, maxHeight: maxHeight)
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { availableWidth = $0 }
            .overlay {
                content.frame(width: size.width, height: size.height)
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: DesignTokens.Media.resizeSeconds), value: aspect)
    }
}

#Preview {
    FittedMediaFrame(aspect: DesignTokens.Media.fallbackAspect, maxHeight: DesignTokens.Media.showcaseMaxHeight) {
        Theme.placeholder
    }
    .padding(DesignTokens.Spacing.xl)
}
