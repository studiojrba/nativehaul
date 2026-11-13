/// A two-layer CSS shadow (spec §2.4): a tight contact layer and a soft, tucked-in ambient layer.
struct ShadowPair: Sendable, Hashable {
    /// The tight contact layer.
    let inner: ShadowLayer
    /// The soft ambient layer.
    let outer: ShadowLayer
}
