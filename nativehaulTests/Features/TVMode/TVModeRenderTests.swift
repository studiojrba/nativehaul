import AppKit
import Foundation
@testable import nativehaul
import SwiftUI
import Testing

/// ADR 0052: renders TV mode's screens offscreen with the sample library, at 1080p and 4K, for visual review of the
/// 10-foot sizing. Mocks only; no controller, no game, nothing on screen.
@MainActor
struct TVModeRenderTests {
    private static let uhd = CGSize(width: 3840, height: 2160)

    private func render(
        _ name: String,
        size: CGSize = DesignTokens.TVMode.previewScreen,
        prepare: (TVModeViewModel) async -> Void = { _ in }
    ) async -> String? {
        let viewModel = AppEnvironment.preview.makeTVModeViewModel()
        viewModel.reload()
        await prepare(viewModel)
        return OffscreenRenderer.render(
            TVModeView(viewModel: viewModel, input: MockTVInputSource()),
            size: size,
            name: "tv-\(name)",
            appearance: .darkAqua
        )
    }

    @Test func theTVScreensRender() async throws {
        let paths = await [
            render("shelves-1080"),
            render("shelves-2160", size: Self.uhd),
            render("grid-1080") { $0.layout = .grid },
            render("detail-1080") { await $0.handle(.details) },
            render("menu-1080") { await $0.handle(.menu) },
            render("detail-nintendo-1080") { model in
                model.setFamily(.nintendo)
                await model.handle(.details)
            },
        ]
        for path in paths {
            let path = try #require(path)
            #expect(FileManager.default.fileExists(atPath: path))
        }
    }
}
