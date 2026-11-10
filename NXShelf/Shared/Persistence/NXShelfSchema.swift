import Foundation
import SwiftData

/// The SwiftData schema for NX Shelf.
enum NXShelfSchema {
    /// All persistent model types.
    static let models: [any PersistentModel.Type] = [
        Game.self,
        PlaySession.self,
        Series.self,
        SeriesEntry.self,
        GameCollection.self,
        SubGame.self,
        GuideLink.self,
    ]
}
