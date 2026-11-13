import SwiftUI

/// The frost segmented pill (spec §3.2 sort control, §3.5 appearance picker): segments at 13pt, the active one on
/// `surface` with `elev-sm`, sliding between options on the house easing.
struct SegmentedPill<Option: Hashable>: View {
    /// The options, in order.
    let options: [Option]
    /// The selected option.
    @Binding var selection: Option
    /// A segment's title.
    let title: (Option) -> String
    /// A segment's SF Symbol, if any.
    var symbol: (Option) -> String? = { _ in nil }

    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                segment(option)
            }
        }
        .padding(KitMetrics.Segmented.padding)
        .frostedGlass(in: Capsule())
        .elevation(.small)
        .animation(reduceMotion ? nil : Motion.settle(), value: selection)
    }

    private func segment(_ option: Option) -> some View {
        let isSelected = option == selection
        return Button { selection = option } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let name = symbol(option) {
                    Image(systemName: name).font(Typeface.sans(KitMetrics.Segmented.iconSize))
                }
                Text(title(option))
            }
            .font(Typeface.sans(TypeStyle.Size.small, weight: isSelected ? .medium : .regular))
            .foregroundStyle(isSelected ? Theme.ink : Theme.inkSoft)
            .padding(.horizontal, KitMetrics.Segmented.horizontal)
            .padding(.vertical, KitMetrics.Segmented.vertical)
            .background {
                if isSelected {
                    Capsule().fill(Theme.surface).elevation(.small)
                        .matchedGeometryEffect(id: "selection", in: namespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var sort = "Recently played"
    AppearancePreviewPair {
        SegmentedPill(options: ["Recently played", "A–Z", "Most played"], selection: $sort) { $0 }
            .padding(DesignTokens.Spacing.xl)
    }
}
