@testable import nativehaul
import SwiftUI

/// The floating sidebar in the real ``RailShell``, with its hover state driven by a probe.
struct RailHoverHarness: View {
    /// The hover state.
    @Bindable var probe: RailHoverProbe
    /// Library state for counts.
    let libraryViewModel: LibraryViewModel

    var body: some View {
        RailShell(
            selection: .constant(.home),
            libraryViewModel: libraryViewModel,
            railExpansion: $probe.isExpanded
        ) {
            NavigationStack { Color.clear }
        }
    }
}
