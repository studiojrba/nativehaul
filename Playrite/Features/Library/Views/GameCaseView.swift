import AppKit
import SceneKit
import SwiftUI

/// The live 3D case (ADR 0039): an `SCNView` with SceneKit's own camera control off; a drag turns the case through
/// ``GameCaseController``.
struct GameCaseView: NSViewRepresentable {
    /// The case's controller.
    let controller: GameCaseController

    func makeNSView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = controller.scene.scene
        view.pointOfView = controller.scene.pointOfView
        view.backgroundColor = .clear
        view.antialiasingMode = .multisampling4X
        view.allowsCameraControl = false
        view.addGestureRecognizer(NSPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.pan(_:))
        ))
        return view
    }

    func updateNSView(_: SCNView, context: Context) {
        context.coordinator.controller = controller
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(controller: controller)
    }

    /// Forwards drags to the controller.
    @MainActor
    final class Coordinator: NSObject {
        /// The case's controller.
        var controller: GameCaseController
        private var last = CGPoint.zero

        init(controller: GameCaseController) {
            self.controller = controller
        }

        /// Handles the pan gesture.
        @objc func pan(_ recognizer: NSPanGestureRecognizer) {
            let point = recognizer.translation(in: recognizer.view)
            switch recognizer.state {
            case .began:
                last = point
                controller.beginDrag()
            case .changed:
                controller.drag(dx: point.x - last.x, dy: -(point.y - last.y))
                last = point
            default:
                controller.endDrag(velocityX: recognizer.velocity(in: recognizer.view).x)
            }
        }
    }
}

#Preview {
    if let art = CaseArtwork.make(for: Game(title: "Preview")) {
        GameCaseView(controller: GameCaseController(artwork: art, tint: .systemOrange))
    } else {
        Text("No cover art in previews").padding(DesignTokens.Spacing.lg)
    }
}
