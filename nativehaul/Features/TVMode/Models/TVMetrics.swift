import SwiftUI

/// TV mode sizes for one screen (ADR 0052): everything scales from the screen height, so a 1080p and a 4K TV look the
/// same from the couch.
struct TVMetrics: Equatable {
    /// Screen size.
    let size: CGSize

    /// Title text size (~4.5% of the height).
    var titleSize: CGFloat {
        size.height * DesignTokens.TVMode.titleShare
    }

    /// Body text size (never below ~2.5%).
    var bodySize: CGFloat {
        size.height * DesignTokens.TVMode.bodyShare
    }

    /// Safe area on the left and right.
    var horizontalInset: CGFloat {
        size.width * DesignTokens.TVMode.safeAreaShare
    }

    /// Safe area at the top and bottom.
    var verticalInset: CGFloat {
        size.height * DesignTokens.TVMode.safeAreaShare
    }

    /// Space between tiles and sections.
    var gap: CGFloat {
        size.height * DesignTokens.TVMode.gapShare
    }

    /// Half a gap (inside a group).
    var halfGap: CGFloat {
        gap / DesignTokens.TVMode.gapDivisor
    }

    /// Two gaps (between groups).
    var doubleGap: CGFloat {
        gap * DesignTokens.TVMode.gapDivisor
    }

    /// Tile height for a layout.
    func tileHeight(_ layout: TVLayout) -> CGFloat {
        size.height * (layout == .shelf ? DesignTokens.TVMode.shelfTileShare : DesignTokens.TVMode.gridTileShare)
    }

    /// Tile width for a layout (portrait box art).
    func tileWidth(_ layout: TVLayout) -> CGFloat {
        tileHeight(layout) * DesignTokens.Cover.widthToHeight
    }

    /// Tile corner radius.
    var tileRadius: CGFloat {
        size.height * DesignTokens.TVMode.tileRadiusShare
    }

    /// Focus shadow radius.
    var focusShadowRadius: CGFloat {
        size.height * DesignTokens.TVMode.focusShadowShare
    }

    /// How far the focused tile lifts.
    var focusLift: CGFloat {
        size.height * DesignTokens.TVMode.focusLiftShare
    }

    /// Detail media height.
    var detailMediaHeight: CGFloat {
        size.height * DesignTokens.TVMode.detailMediaShare
    }

    /// Menu panel width.
    var menuWidth: CGFloat {
        size.width * DesignTokens.TVMode.menuWidthShare
    }

    /// How many grid columns fit inside the safe area.
    var gridColumns: Int {
        let usable = size.width - horizontalInset - horizontalInset
        let column = tileWidth(.grid) + gap
        guard column > 0 else { return DesignTokens.TVMode.minimumColumns }
        return max(Int((usable + gap) / column), DesignTokens.TVMode.minimumColumns)
    }

    /// Title font.
    var titleFont: Font {
        .system(size: titleSize, weight: .heavy, design: .rounded)
    }

    /// Body font.
    var bodyFont: Font {
        .system(size: bodySize)
    }

    /// Emphasised body font (tile titles, menu rows).
    var bodyEmphasisFont: Font {
        .system(size: bodySize, weight: .semibold)
    }
}
