import SwiftUI

// Scene metrics are token source (spec §3.6 "Scenes"), so the magic-number rule is off here.
// swiftlint:disable no_magic_numbers

extension ShellLayout {
    /// Onboarding's preview scenes (spec §3.6).
    enum OnboardingScenes {
        /// The four floating wash squares on page 1: size, centre (share of the cluster) and float delay.
        static let squares: [FloatingSquare] = [
            FloatingSquare(size: 112, center: UnitPoint(x: 0.04 + 0.08, y: 0.12 + 0.15), delay: 0, slot: .blush),
            FloatingSquare(size: 144, center: UnitPoint(x: 0.98 - 0.11, y: 0.14 + 0.19), delay: 1.2, slot: .sky),
            FloatingSquare(size: 96, center: UnitPoint(x: 0.02 + 0.07, y: 0.98 - 0.13), delay: 2.1, slot: .mint),
            FloatingSquare(size: 80, center: UnitPoint(x: 0.86 - 0.06, y: 1.0 - 0.11), delay: 0.6, slot: .butter),
        ]
        /// Square corner radius as a share of its side.
        static let squareRadiusShare: CGFloat = 0.34

        /// Shelf panel padding.
        static let shelfPadding: CGFloat = 28
        /// Shelf panel `surface` opacity.
        static let shelfOpacity: Double = 0.60
        /// Header bar horizontal padding.
        static let barHorizontal: CGFloat = 16
        /// Header bar vertical padding.
        static let barVertical: CGFloat = 12
        /// Header bar folder icon.
        static let barIcon: CGFloat = 16
        /// Header bar to grid.
        static let gridTop: CGFloat = 24
        /// Shelf columns.
        static let shelfColumns = 6
        /// Shelf gap.
        static let shelfGap: CGFloat = 12
        /// Cover rise stagger (seconds).
        static let coverStagger: Double = 0.07
        /// Placeholder dashed border: `ink` at this opacity.
        static let dashOpacity: Double = 0.10
        /// Dashed border width.
        static let dashWidth: CGFloat = 2
        /// Dash pattern.
        static let dash: [CGFloat] = [6, 5]

        /// Drive cards: maximum width of the pair.
        static let diskMaxWidth: CGFloat = 560
        /// Drive card gap.
        static let diskGap: CGFloat = 20
        /// Drive card padding.
        static let diskPadding: CGFloat = 24
        /// Unselected drive card scale.
        static let diskDimScale: CGFloat = 0.95
        /// Unselected drive card opacity.
        static let diskDimOpacity: Double = 0.70
        /// Unselected drive card `surface` opacity.
        static let diskDimFill: Double = 0.40
        /// Drive icon chip.
        static let diskChip: CGFloat = 64
        /// Drive icon glyph.
        static let diskIcon: CGFloat = 26
        /// Chip to name.
        static let diskNameTop: CGFloat = 24
        /// Usage bar height.
        static let usageHeight: CGFloat = 10
        /// Name size.
        static let diskName: CGFloat = 18

        /// Keys drop zone maximum width.
        static let keysMaxWidth: CGFloat = 520
        /// Keys drop zone aspect (4:3).
        static let keysAspect: CGFloat = 4.0 / 3.0
        /// Drop zone dashed border: `ink` at this opacity.
        static let keysDashOpacity: Double = 0.15
        /// Drop zone fill: `surface` at this opacity.
        static let keysFill: Double = 0.40
        /// The floating file card.
        static let fileCard = CGSize(width: 112, height: 144)
        /// The file card's tilt (degrees).
        static let fileTilt: Double = -6
        /// The folded corner.
        static let fileFold: CGFloat = 32
        /// The file card's key glyph.
        static let fileIcon: CGFloat = 36
        /// Caption inset from the zone's bottom.
        static let captionBottom: CGFloat = 24
        /// Steps card padding.
        static let stepsPadding: CGFloat = 24
        /// Steps card top margin.
        static let stepsTop: CGFloat = 24
        /// Steps card radius.
        static let stepsRadius: CGFloat = 24
        /// Drop zone highlight when a file hovers over it: accent at this opacity.
        static let dropTargetOpacity: Double = 0.60

        /// Player cards: maximum width of the grid.
        static let playerMaxWidth: CGFloat = 600
        /// Player banner padding.
        static let bannerHorizontal: CGFloat = 20
        /// Player banner vertical padding.
        static let bannerVertical: CGFloat = 12
        /// Banner `mint` opacity.
        static let bannerOpacity: Double = 0.80
        /// Player chip.
        static let playerChip: CGFloat = 64
        /// Player chip radius.
        static let playerChipRadius: CGFloat = 22
        /// Player initial size.
        static let playerInitial: CGFloat = 34
        /// Player name size.
        static let playerName: CGFloat = 20
        /// Selected card lift.
        static let playerLift: CGFloat = -8
        /// Unselected card fill: `surface` at this opacity.
        static let playerDimFill: Double = 0.45
        /// Status pill padding.
        static let statusHorizontal: CGFloat = 12
        /// Status pill vertical padding.
        static let statusVertical: CGFloat = 4
        /// Most player cards shown.
        static let maximumPlayers = 6

        /// The TV screen's aspect (16:9).
        static let screenAspect: CGFloat = 16.0 / 9.0
        /// TV mock maximum width.
        static let tvMaxWidth: CGFloat = 640
        /// TV bezel radius.
        static let tvRadius: CGFloat = 28
        /// TV bezel padding.
        static let tvBezel: CGFloat = 12
        /// Screen radius.
        static let screenRadius: CGFloat = 18
        /// Screen padding.
        static let screenPadding: CGFloat = 24
        /// Title size.
        static let tvTitle: CGFloat = 34
        /// First cover.
        static let tvFocused = CGSize(width: 80, height: 112)
        /// Other covers.
        static let tvCover = CGSize(width: 68, height: 96)
        /// Covers on the TV.
        static let tvCovers = 6
        /// Focus ring width.
        static let tvRing: CGFloat = 2
        /// Stand size.
        static let standSize = CGSize(width: 160, height: 20)
        /// Stand `bezel` opacity.
        static let standOpacity: Double = 0.80
        /// Dimmed TV (desk hovered) scale.
        static let tvDimScale: CGFloat = 0.95
        /// Dimmed TV opacity.
        static let tvDimOpacity: Double = 0.40
        /// Mode pills padding.
        static let modeHorizontal: CGFloat = 16
        /// Mode pills vertical padding.
        static let modeVertical: CGFloat = 8
        /// Mode pills gap.
        static let modeGap: CGFloat = 24
        /// Note card top margin.
        static let noteTop: CGFloat = 20
        /// Note card padding.
        static let notePadding: CGFloat = 20
    }
}

// swiftlint:enable no_magic_numbers
