//
//  SponsorTransformer.swift
//  
//
//  Created by Alex Logan on 01/08/2022.
//

import Foundation

enum SponsorTransformer: Transformer {
    static func transform(_ entity: Sponsor?) -> SponsorResponse? {
        guard let entity = entity else { return nil }
        return .init(
            id: entity.id,
            name: entity.name,
            image: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/\(entity.image)", // Hard coded in absence of environment variables
            url: entity.url,
            sponsorLevel: .init(rawValue: entity.sponsorLevel.rawValue)
        )
    }
}
