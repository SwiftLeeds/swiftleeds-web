import Foundation

enum LocationTransformer: Transformer {
    static func transform(_ entity: Location?) -> LocationResponse? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }

        return LocationResponse(
            id: id,
            name: entity.name,
            lat: entity.lat,
            long: entity.long,
            url: entity.url
        )
    }
}
