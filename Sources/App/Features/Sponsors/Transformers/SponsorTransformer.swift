import Foundation
import Vapor

enum SponsorTransformer: Transformer {
    static func transform(_ entity: Sponsor?) -> SponsorResponse? {
        guard let entity = entity else {
            return nil
        }
        
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            fatalError("Missing 'S3_BUCKET_NAME' environment variable")
        }
        
        return .init(
            id: entity.id,
            name: entity.name,
            subtitle: entity.subtitle,
            image: "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(entity.image)",
            url: entity.url,
            sponsorLevel: .init(rawValue: entity.sponsorLevel.rawValue)
        )
    }
}
