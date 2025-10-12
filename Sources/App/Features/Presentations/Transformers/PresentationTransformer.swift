import Foundation

enum PresentationTransformer: Transformer {
    static func transform(_ entity: Presentation?) -> PresentationResponse? {
        guard let entity, let id = entity.id else {
            return nil
        }

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

        return PresentationResponse(
            id: id,
            title: entity.title,
            synopsis: entity.synopsis,
            speakers: [speaker, secondSpeaker].compactMap(\.self),
            slidoURL: entity.slidoURL,
            videoURL: entity.videoVisibility == .shared ? entity.videoURL : nil
        )
    }
}
