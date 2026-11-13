import SwiftUI

/// Couch's header (spec §3.7): "nativehaul" on the left (26pt semibold), the status pill on the right.
struct CouchHeader: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    var body: some View {
        let scale = viewModel.scale
        HStack {
            Text("nativehaul")
                .font(Typeface.sans(scale(CouchLayout.Header.wordmark), weight: .semibold))
                .foregroundStyle(Theme.ink)
            Spacer(minLength: 0)
            CouchStatusPill(
                status: viewModel.controllerStatus,
                isConnected: viewModel.controllerFamily != nil,
                clock: viewModel.clockText,
                scale: scale
            )
        }
        .padding(.horizontal, scale(CouchLayout.gutter))
        .padding(.top, scale(CouchLayout.Header.top))
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    AppearancePreviewPair {
        CouchHeader(viewModel: .preview)
            .frame(width: CouchLayout.previewHalf.width, height: CouchLayout.previewHalf.height)
    }
}
