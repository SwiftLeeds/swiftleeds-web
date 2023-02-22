import Foundation
import Vapor

enum PastSponsorTransformer: Transformer {
    static func transform(_ entity: PastSponsor?) -> PastSponsorResponse? {
        guard let entity = entity else {
            return nil
        }
        
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            fatalError("Missing 'S3_BUCKET_NAME' environment variable")
        }
        
        return .init(
            id: entity.id,
            name: entity.name,
            image: "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(entity.image)",
            url: entity.url
        )
    }
}
