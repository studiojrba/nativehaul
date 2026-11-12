import SwiftUI

/// Hosts TV mode inside the main window (ADR 0052). On ``TVModeRequest`` the window goes full screen and TV mode
/// covers the desktop layout, which stays alive underneath; Exit TV Mode hands the window back exactly as it was.
/// With TV mode off, the desktop window is untouched.
struct TVModeHost: ViewModifier {
    /// App dependencies.
    let environment: AppEnvironment
    /// Called after TV mode closes (the library may have changed).
    var onExit: @MainActor () -> Void = {}
    @State private var viewModel: TVModeViewModel?

    func body(content: Content) -> some View {
        content
            .toolbar(viewModel == nil ? .automatic : .hidden, for: .windowToolbar)
            .overlay {
                if let viewModel {
                    TVModeView(viewModel: viewModel, input: environment.makeTVInput())
                        .background(TVFullScreenWindow())
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: TVModeRequest.name)) { _ in enter() }
    }

    private func enter() {
        guard viewModel == nil else { return }
        let model = environment.makeTVModeViewModel()
        model.onExit = {
            viewModel = nil
            onExit()
        }
        viewModel = model
    }
}
