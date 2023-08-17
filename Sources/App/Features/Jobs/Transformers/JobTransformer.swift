//import Foundation
import Vapor

enum JobTransformer: Transformer {
    static func transform(_ entity: Job?) -> JobResponse? {
        guard let entity else { return nil }

        return .init(
            id: entity.id,
            title: entity.title,
            location: entity.location,
            details: entity.details,
            url: entity.url
        )
    }
}
