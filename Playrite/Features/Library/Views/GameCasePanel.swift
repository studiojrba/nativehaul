import AppKit
import SwiftUI

/// The detail page's sticky left panel (ADR 0039). With cover art it shows the 3D case with zoom buttons at its
/// edge; without, the plain media treatment (the hero, or the cover, fitted whole).
struct GameCasePanel: View {
    /// What to print on the case, or `nil` for the plain panel.
    let artwork: CaseArtwork?
    /// Art for the plain panel.
    let fallbackImagePath: String?
    @State private var controller: GameCaseController?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.gameCaseRendersStill) private var rendersStill

    var body: some View {
        Group {
            if let controller {
                caseView(controller)
            } else if artwork == nil {
                plainPanel
            } else {
                Color.clear
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .frame(width: DesignTokens.GameCase.panelWidth)
        .frame(maxHeight: .infinity)
        .task(id: artwork) { prepare() }
        .onChange(of: reduceMotion) { controller?.reduceMotion = reduceMotion }
        .onDisappear { controller?.pause() }
    }

    private func caseView(_ controller: GameCaseController) -> some View {
        Group {
            if rendersStill, let still = controller.scene.snapshot(size: CGSize(
                width: DesignTokens.GameCase.panelWidth,
                height: DesignTokens.GameCase.panelWidth / DesignTokens.GameCase.faceAspect
            )) {
                Image(nsImage: still).resizable().scaledToFit()
            } else {
                GameCaseView(controller: controller)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottomTrailing) { zoomButtons(controller) }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Game case for \(artwork?.spineTitle ?? "this game"). Drag to turn it.")
    }

    private func zoomButtons(_ controller: GameCaseController) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Button("Zoom in", systemImage: "plus", action: controller.zoomIn).disabled(!controller.canZoomIn)
            Button("Zoom out", systemImage: "minus", action: controller.zoomOut).disabled(!controller.canZoomOut)
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .font(DesignTokens.Typography.title)
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
    }

    @ViewBuilder private var plainPanel: some View {
        if let image = fallbackImagePath.flatMap(NSImage.init(contentsOfFile:)) {
            Image(nsImage: image).resizable().scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                .frame(maxHeight: .infinity)
        } else {
            Theme.placeholder
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                .aspectRatio(DesignTokens.GameCase.faceAspect, contentMode: .fit)
                .overlay {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundStyle(Theme.secondaryText)
                }
                .frame(maxHeight: .infinity)
        }
    }

    private func prepare() {
        guard let artwork else {
            controller = nil
            return
        }
        let tint = ArtworkTint.nsColor(forImageAt: artwork.frontPath) ?? Palette.color(Palette.muted)
        let controller = GameCaseController(artwork: artwork, tint: tint)
        controller.reduceMotion = reduceMotion
        self.controller = controller
    }
}

#Preview {
    GameCasePanel(artwork: nil, fallbackImagePath: nil)
        .frame(height: DesignTokens.Layout.windowMinHeight)
}
