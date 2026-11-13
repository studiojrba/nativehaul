import SwiftUI

/// Page 1's logo cluster (spec §3.6): four soft wash squares floating behind the 144pt n. mark, the "nativehaul"
/// wordmark at 56pt display and the tagline.
struct WelcomeLogoCluster: View {
    /// The cluster's height (`clamp(300px, 42vh, 380px)`).
    let height: CGFloat

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ForEach(Array(ShellLayout.OnboardingScenes.squares.enumerated()), id: \.offset) { _, square in
                    RoundedRectangle(
                        cornerRadius: square.size * ShellLayout.OnboardingScenes.squareRadiusShare,
                        style: .continuous
                    )
                    .fill(Theme.wash(square.slot))
                    .frame(width: square.size, height: square.size)
                    .elevation(.small)
                    .modifier(DelayedFloat(delay: square.delay))
                    .position(x: square.center.x * proxy.size.width, y: square.center.y * proxy.size.height)
                }
            }
            VStack(spacing: 0) {
                AppMark()
                    .frame(width: ShellLayout.Onboarding.welcomeMark, height: ShellLayout.Onboarding.welcomeMark)
                    .elevation(.large)
                Text(AppInfo.productName)
                    .font(Typeface.display(TypeStyle.DisplaySize.wordmark))
                    .foregroundStyle(Theme.ink)
                    .padding(.top, ShellLayout.Onboarding.wordmarkTop)
                Text("Your game shelf, on your Mac.")
                    .font(Typeface.sans(TypeStyle.Size.label))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.top, ShellLayout.Onboarding.taglineTop)
            }
            .modifier(DelayedFloat(delay: 0, duration: ShellLayout.Onboarding.welcomeMarkFloat))
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AppearancePreviewPair {
        WelcomeLogoCluster(height: ShellLayout.Onboarding.clusterMax)
            .frame(width: ShellLayout.Onboarding.welcomeMaxWidth)
    }
}
