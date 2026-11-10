import SwiftUI

extension EnvironmentValues {
    /// The guided tour, so highlighted controls can glow and report use (ADR 0040).
    @Entry var onboardingGuide: OnboardingGuide?
    /// When true, the tour's lines appear whole (renders and tests; Reduce Motion does the same for people).
    @Entry var guideTypesInstantly = false
}
