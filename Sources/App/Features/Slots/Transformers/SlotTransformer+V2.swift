import Foundation

enum SlotTransformerV2: Transformer {
    static func transform(_ entity: Slot?) -> SlotResponseV2? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }

        let presentation: PresentationResponseV2?
        let activity: ActivityResponse?

        if let presentationEntity = entity.$presentation.value, presentationEntity?.isTBA == true {
            presentation = PresentationTransformerV2.transform(presentationEntity)
        } else {
            presentation = nil
        }

        if let activityEntity = entity.$activity.value {
            activity = ActivityTransformer.transform(activityEntity)
        } else {
            activity = nil
        }

        if activity == nil && presentation == nil {
            return nil
        }

        return .init(
            id: id,
            startTime: entity.startDate,
            date: entity.date,
            duration: entity.duration,
            presentation: presentation,
            activity: activity
        )
    }
}
