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
        return .init(
            id: entity.id,
            name: entity.name,
            biography: entity.biography,
            profileImage: entity.profileImage,
            twitter: entity.twitter,
            organisation: entity.organisation,
            presentations: entity.presentations.compactMap(PresentationTransformer.transform)
        )
    }
}
