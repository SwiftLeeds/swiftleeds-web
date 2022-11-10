import Foundation

enum ActivityTransformer: Transformer {
    static func transform(_ entity: Activity?) -> ActivityResponse? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }

        var entityImage: String? = entity.image

        if let image = entityImage {
            entityImage = ImageTransformer.transform(imageURL: image)
        }

        return .init(
            id: id,
            title: entity.title,
            subtitle: entity.subtitle,
            description: entity.$description.wrappedValue ?? "",
            metadataURL: entity.metadataURL,
            image: entityImage
        )
    }
}
