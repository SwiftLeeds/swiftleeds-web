import Foundation
import Vapor

enum LocationCategoryTransformer: Transformer {
    static func transform(_ entity: LocationCategory?) -> LocationCategoryResponse? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }

        return LocationCategoryResponse(
            id: id,
            name: entity.name,
            symbolName: entity.symbolName,
            locations: entity.locations.compactMap(LocationTransformer.transform(_:))
        )
    }
}
