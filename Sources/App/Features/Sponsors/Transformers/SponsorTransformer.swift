//
//  SponsorTransformer.swift
//  
//
//  Created by Alex Logan on 01/08/2022.
//

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
            // TODO: figure this out
            image: "https://\(bucketName).s3.eu-west-2.amazonaws.com/\(entity.image)", // Hard coded in absence of environment variables
            url: entity.url,
            sponsorLevel: .init(rawValue: entity.sponsorLevel.rawValue)
        )
    }
}
