import Foundation

extension CouchViewModel {
    /// Couch over the seeded preview library, with mock services, sized like the smallest window.
    static var preview: CouchViewModel {
        let environment = AppEnvironment.preview
        let library = environment.makeLibraryViewModel()
        let builds = BuildsViewModel(
            queue: environment.makeNXNativeViewModel {},
            library: { library.games },
            paletteExtractor: environment.paletteExtractor
        )
        let home = HomeViewModel(library: library, paletteExtractor: environment.paletteExtractor)
        let viewModel = environment.makeCouchViewModel(home: home, library: library, builds: builds) {}
        viewModel.updateSize(CGSize(
            width: DesignTokens.Layout.windowMinWidth,
            height: DesignTokens.Layout.windowMinHeight
        ))
        return viewModel
    }
}
