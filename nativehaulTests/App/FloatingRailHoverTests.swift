import AppKit
@testable import nativehaul
import SwiftUI
import Testing

/// Round 2.1 (ADR 0037): hovering the floating sidebar widens it to the right only. Its top and bottom edges never
/// move, at rest, mid-animation or expanded, at every window height and dial position.
///
/// The check reads a one-pixel column through the panel's left margin (left of the nav rows, inside the panel): it
/// crosses the panel's top and bottom edges, corners and shadow, and nothing that changes with width. If the panel
/// moves or resizes vertically at all, the column changes.
@MainActor
struct FloatingRailHoverTests {
    private static let width: CGFloat = 600
    private static let heights: [CGFloat] = [1100, 640, 420]
    private static let animationSeconds: TimeInterval = 0.5
    private static let sampleSeconds: TimeInterval = 0.04
    private static let settleSeconds: TimeInterval = 0.5
    private static let tolerance = 2
    private static let offscreen: CGFloat = -20000
    /// Just inside the panel's left edge, left of anything the rows draw.
    private static let columnX = DesignTokens.FloatingRail.margin + DesignTokens.Spacing.xxs

    @Test(arguments: DesignIntensity.allCases)
    func hoverNeverMovesThePanelVertically(intensity: DesignIntensity) throws {
        let environment = try LibraryRenderFixture.environment()
        for height in Self.heights {
            for titled in [true, false] {
                try checkHover(environment: environment, intensity: intensity, height: height, titled: titled)
            }
        }
    }

    /// Collapsed rows fit the panel exactly, so the content never re-centres while the width animates.
    @Test func collapsedRowsFitThePanel() {
        let inner = DesignTokens.Rail.collapsedWidth - DesignTokens.Spacing.xs * 2
        #expect(inner == DesignTokens.Rail.iconWidth + DesignTokens.Spacing.md * 2)
    }

    private func checkHover(
        environment: AppEnvironment,
        intensity: DesignIntensity,
        height: CGFloat,
        titled: Bool
    ) throws {
        let probe = RailHoverProbe()
        let view = RailHoverHarness(probe: probe, libraryViewModel: environment.makeLibraryViewModel())
            .environment(\.designIntensity, intensity)
            .environment(environment)
            .modelContainer(environment.container)
        let frames = Self.capture(view, height: height, titled: titled) {
            withAnimation(.easeInOut(duration: Self.animationSeconds)) { probe.isExpanded = true }
        }
        let resting = try #require(frames.first)
        for (index, frame) in frames.enumerated().dropFirst() {
            let row = Self.firstDifferingRow(resting, frame)
            #expect(
                row == nil,
                "\(intensity) at \(Int(height)) pt, titled \(titled): frame \(index) differs from rest at row \(row ?? 0)"
            )
        }
    }

    /// Renders `view`, captures the column at rest, runs `change`, then captures it through the animation and after.
    private static func capture(_ view: some View, height: CGFloat, titled: Bool, change: () -> Void) -> [[UInt8]] {
        let size = CGSize(width: width, height: height)
        let hosting = NSHostingView(rootView: view.frame(width: size.width, height: size.height))
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: titled ? [.titled, .resizable, .fullSizeContentView] : [.borderless],
            backing: .buffered,
            defer: false
        )
        if titled {
            window.toolbar = NSToolbar()
            window.titlebarAppearsTransparent = true
        }
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = hosting
        window.setFrameOrigin(NSPoint(x: offscreen, y: offscreen))
        window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        RunLoop.main.run(until: Date().addingTimeInterval(settleSeconds))
        var frames = [column(of: hosting)]
        change()
        let end = Date().addingTimeInterval(animationSeconds + settleSeconds)
        while Date() < end {
            RunLoop.main.run(until: Date().addingTimeInterval(sampleSeconds))
            frames.append(column(of: hosting))
        }
        return frames
    }

    private static func column(of view: NSView) -> [UInt8] {
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return [] }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        let scale = CGFloat(bitmap.pixelsWide) / view.bounds.width
        let x = Int(columnX * scale)
        var pixels: [UInt8] = []
        for y in 0 ..< bitmap.pixelsHigh {
            guard let color = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.deviceRGB) else { continue }
            pixels += [color.redComponent, color.greenComponent, color.blueComponent].map { UInt8($0 * 255) }
        }
        return pixels
    }

    private static func firstDifferingRow(_ lhs: [UInt8], _ rhs: [UInt8]) -> Int? {
        guard lhs.count == rhs.count else { return 0 }
        let channels = 3
        for index in lhs.indices where abs(Int(lhs[index]) - Int(rhs[index])) > tolerance {
            return index / channels
        }
        return nil
    }
}
