import Foundation
import Vapor

enum SponsorTransformer: Transformer {
    static func transform(_ sponsor: Sponsor?) -> SponsorResponse? {
        guard let sponsor else {
            return nil
        }
        
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            fatalError("Missing 'S3_BUCKET_NAME' environment variable")
        }
        
        return .init(
            id: sponsor.id,
            name: sponsor.name,
            subtitle: sponsor.subtitle,
            image: "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(sponsor.image)",
            url: sponsor.url,
            sponsorLevel: .init(rawValue: sponsor.sponsorLevel.rawValue),
            jobs: sponsor.jobs.compactMap(JobTransformer.transform)
        )
    }
}
