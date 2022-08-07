//
//  SpeakerTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum SpeakerTransformer: Transformer {
    static func transform(_ entity: Speaker?) -> SpeakerResponse? {
        guard let entity = entity else {
            return nil
        }

        let presentations: [PresentationResponse]

        if let presentationEntities = entity.$presentations.value {
            presentations = presentationEntities.compactMap(PresentationTransformer.transform(_:))
        } else {
            presentations = []
        }

        return .init(
            id: entity.id,
            name: entity.name,
            biography: entity.biography,
            profileImage: ImageTransformer.transform(imageURL: entity.profileImage),
            twitter: entity.twitter,
            organisation: entity.organisation,
            presentations: presentations
        )
    }
}
