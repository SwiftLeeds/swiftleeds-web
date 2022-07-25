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

        let speaker: SpeakerResponse?

        if let speakerEntity = entity.$speaker.value {
            speaker = SpeakerTransformer.transform(speakerEntity)
        } else {
            speaker = nil
        }

        return PresentationResponse(
            id: entity.id,
            title: entity.title,
            synopsis: entity.synopsis,
            image: entity.image,
            speaker: speaker
        )
    }
}
