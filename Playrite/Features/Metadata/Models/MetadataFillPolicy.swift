import Foundation

/// Decides which fields a metadata pass may write. The single place these rules live.
///
/// - User-set fields (``MetadataSource/user``) are never written.
/// - Empty fields are always fillable.
/// - In ``MetadataFetchMode/fillMissing`` nothing that has a value is touched.
/// - In ``MetadataFetchMode/refresh``, text that was fetched or imported may be replaced, but art is replaced
///   only when a previous pass downloaded it. Art with no recorded source is treated as manual and kept.
@MainActor
enum MetadataFillPolicy {
    /// Fields a pass in `mode` may write for `game`.
    static func writableFields(for game: Game, mode: MetadataFetchMode) -> Set<MetadataField> {
        Set(MetadataField.allCases.filter { canWrite($0, for: game, mode: mode) })
    }

    /// Whether a pass in `mode` may write `field` for `game`.
    static func canWrite(_ field: MetadataField, for game: Game, mode: MetadataFetchMode) -> Bool {
        let source = game.metadataProvenance[field]
        if source == .user {
            return false
        }
        if game.isMissing(field) {
            return true
        }
        switch mode {
        case .fillMissing:
            return false
        case .refresh:
            return field.isArtwork ? source?.isFetched == true : true
        }
    }
}
