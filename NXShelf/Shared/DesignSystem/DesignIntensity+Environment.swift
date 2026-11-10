import SwiftUI

extension EnvironmentValues {
    /// The energy dial position views read their energy tokens from (ADR 0037).
    @Entry var designIntensity: DesignIntensity = .current
}
