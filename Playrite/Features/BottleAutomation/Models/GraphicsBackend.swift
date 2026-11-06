import Foundation

/// How a bottle translates DirectX.
enum GraphicsBackend: String, Codable, Sendable {
    /// Apple's D3DMetal (DirectX 11/12).
    case d3dMetal
    /// DXMT (DirectX 11 on Metal).
    case dxmt
    /// DXVK (DirectX 9–11 over Vulkan/MoltenVK).
    case dxvk

    /// Value written to the bottle's graphics-backend setting.
    var settingValue: String {
        rawValue.lowercased()
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .d3dMetal: "D3DMetal"
        case .dxmt: "DXMT"
        case .dxvk: "DXVK"
        }
    }
}
