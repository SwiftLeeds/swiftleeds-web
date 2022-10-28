//
//  PresentationTransformerV2.swift
//  
//
//  Created by Alex Logan on 18/08/2022.
//

import Foundation

enum PresentationTransformerV2: Transformer {
    static func transform(_ entity: Presentation?) -> PresentationResponseV2? {
        guard let entity = entity, let id = entity.id else { return nil }

        let speaker: SpeakerResponse?
        let secondSpeaker: SpeakerResponse?

        if let speakerEntity = entity.$speaker.value {
            speaker = SpeakerTransformer.transform(speakerEntity)
        } else {
            speaker = nil
        }

        if let secondSpeakerEntity = entity.$secondSpeaker.value {
            secondSpeaker = SpeakerTransformer.transform(secondSpeakerEntity)
        } else {
            secondSpeaker = nil
        }

        return PresentationResponseV2(
            id: id,
            title: entity.title,
            synopsis: entity.synopsis,
            speakers: [speaker, secondSpeaker].compactMap { $0 },
            slidoURL: entity.slidoURL
        )
    }
}
