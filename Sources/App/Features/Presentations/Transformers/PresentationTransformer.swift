//
//  PresentationTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum PresentationTransformer: Transformer {
    static func transform(_ entity: Presentation?) -> PresentationResponse? {
        guard let entity = entity else {
            return nil
        }
        return PresentationResponse(
            id: entity.id,
            title: entity.title,
            synopsis: entity.synopsis,
            image: entity.image,
            speaker: SpeakerTransformer.transform(entity.speaker)
        )
    }
}
