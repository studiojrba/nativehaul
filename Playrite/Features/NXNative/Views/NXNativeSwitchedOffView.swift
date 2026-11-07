import SwiftUI

/// Shown only when the user switched the module off in Settings (it is on by default, ADR 0021).
struct NXNativeSwitchedOffView: View {
    /// Turns the module back on.
    let onTurnOn: () -> Void

    var body: some View {
        EmptyStateView(
            title: NXNativeReadiness.switchedOffTitle,
            symbolName: "hammer",
            message: NXNativeReadiness.switchedOffMessage
        ) {
            Button(NXNativeReadiness.turnOnTitle, action: onTurnOn).buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    NXNativeSwitchedOffView {}
}
