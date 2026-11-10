import AppKit
import Metal
import SceneKit

/// The 3D game case (ADR 0039): one box of the shared case proportion, its faces printed from ``CaseArtwork``, lit
/// softly, on a clear background so the panel shows through.
@MainActor
final class GameCaseScene {
    private typealias Tokens = DesignTokens.GameCase

    /// The scene SceneKit renders.
    let scene = SCNScene()
    private let caseNode: SCNNode
    private let cameraNode = SCNNode()

    /// Builds the case for `artwork`, its edges in `tint` (sampled from the art).
    init(artwork: CaseArtwork, tint: NSColor) {
        let box = SCNBox(
            width: Tokens.width,
            height: Tokens.height,
            length: Tokens.depth,
            chamferRadius: Tokens.chamfer
        )
        let edge = GameCaseTextures.edgeColor(from: tint)
        // SCNBox material order: front, right, back, left, top, bottom. The spine is the left face, which the resting
        // angle turns toward the camera.
        box.materials = [
            Self.material(GameCaseTextures.face(from: artwork.frontPath) ?? edge),
            Self.material(edge),
            Self.material(GameCaseTextures.face(from: artwork.backPath) ?? edge),
            Self.material(GameCaseTextures.spine(title: artwork.spineTitle, color: edge)),
            Self.material(edge),
            Self.material(edge),
        ]
        caseNode = SCNNode(geometry: box)
        scene.rootNode.addChildNode(caseNode)
        let camera = SCNCamera()
        camera.fieldOfView = Tokens.fieldOfView
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, Tokens.cameraRest)
        scene.rootNode.addChildNode(cameraNode)
        addLights()
        scene.background.contents = NSColor.clear
        apply(CaseMotion())
    }

    /// The camera node (the view renders through it).
    var pointOfView: SCNNode {
        cameraNode
    }

    /// Turns the case to `motion`'s angles.
    func apply(_ motion: CaseMotion) {
        caseNode.eulerAngles = SCNVector3(motion.pitch, motion.yaw, 0)
    }

    /// Moves the camera to `distance`, animated over `duration` seconds.
    func setCameraDistance(_ distance: CGFloat, duration: Double) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        cameraNode.position = SCNVector3(0, 0, distance)
        SCNTransaction.commit()
    }

    /// A still of the case at `size` points (2× pixels), rendered offscreen. Used where a live view can't be captured.
    func snapshot(size: CGSize) -> NSImage? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let renderer = SCNRenderer(device: device, options: nil)
        renderer.scene = scene
        renderer.pointOfView = cameraNode
        let scale: CGFloat = 2
        return renderer.snapshot(
            atTime: 0,
            with: CGSize(width: size.width * scale, height: size.height * scale),
            antialiasingMode: .multisampling4X
        )
    }

    private func addLights() {
        let key = SCNNode()
        key.light = SCNLight()
        key.light?.type = .directional
        key.light?.intensity = Tokens.keyLightIntensity
        key.eulerAngles = SCNVector3(Tokens.keyLightPitch, Tokens.keyLightYaw, 0)
        scene.rootNode.addChildNode(key)
        let fill = SCNNode()
        fill.light = SCNLight()
        fill.light?.type = .ambient
        fill.light?.intensity = Tokens.fillLightIntensity
        scene.rootNode.addChildNode(fill)
    }

    private static func material(_ contents: Any) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = contents
        material.lightingModel = .blinn
        material.specular.contents = NSColor(white: Tokens.gloss, alpha: 1)
        return material
    }
}
