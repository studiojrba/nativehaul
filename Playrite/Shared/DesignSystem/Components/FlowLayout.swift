import SwiftUI

/// Wrapping horizontal layout for chips (genres, tags).
struct FlowLayout: Layout {
    /// Gap between items and rows.
    var spacing: CGFloat = DesignTokens.Spacing.xs

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? DesignTokens.Spacing.none
        let height = rows.map(\.height).reduce(DesignTokens.Spacing.none, +)
            + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews, width: bounds.width) {
            var x = bounds.minX
            for index in row.indices {
                let size = fittedSize(of: subviews[index], maxWidth: bounds.width)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = DesignTokens.Spacing.none
        var height: CGFloat = DesignTokens.Spacing.none
    }

    /// The item's ideal size, or — when that's wider than a row — its size at the row's width (so text wraps instead
    /// of running past the edge).
    private func fittedSize(of subview: LayoutSubview, maxWidth: CGFloat) -> CGSize {
        let ideal = subview.sizeThatFits(.unspecified)
        guard ideal.width > maxWidth, maxWidth.isFinite else { return ideal }
        return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
    }

    private func arrange(_ subviews: Subviews, width maxWidth: CGFloat) -> [Row] {
        var rows = [Row()]
        for index in subviews.indices {
            let size = fittedSize(of: subviews[index], maxWidth: maxWidth)
            let lastIndex = rows.count - 1
            let needed = rows[lastIndex].indices.isEmpty ? size.width : rows[lastIndex].width + spacing + size.width
            if needed > maxWidth, !rows[lastIndex].indices.isEmpty {
                rows.append(Row(indices: [index], width: size.width, height: size.height))
            } else {
                rows[lastIndex].indices.append(index)
                rows[lastIndex].width = needed
                rows[lastIndex].height = max(rows[lastIndex].height, size.height)
            }
        }
        return rows
    }
}

#Preview {
    FlowLayout {
        ForEach(["Action", "Roguelite", "Pixel Art", "Co-op", "Metroidvania"], id: \.self) {
            TagLabel(text: $0, symbolName: "tag", tint: Theme.info)
        }
    }
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}
