import SwiftUI

/// Shown only when the user switched the module off in Settings (it is on by default, ADR 0021).
struct NXNativeSwitchedOffView: View {
    /// Turns the module back on.
    let onTurnOn: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(NXNativeReadiness.switchedOffTitle, systemImage: "hammer")
        } description: {
            Text(NXNativeReadiness.switchedOffMessage)
        } actions: {
            Button(NXNativeReadiness.turnOnTitle, action: onTurnOn)
        }
    }
}

#Preview {
    NXNativeSwitchedOffView {}
}
