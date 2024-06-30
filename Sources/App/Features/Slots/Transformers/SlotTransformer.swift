import Foundation

enum SlotTransformer: Transformer {
    static func transform(_ entity: Slot?) -> SlotResponse? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }

        let presentation: PresentationResponse?
        let activity: ActivityResponse?

        if let presentationEntity = entity.$presentation.value {
            presentation = PresentationTransformer.transform(presentationEntity)
        } else {
            presentation = nil
        }

        if let activityEntity = entity.$activity.value {
            activity = ActivityTransformer.transform(activityEntity)
        } else {
            activity = nil
        }

        return .init(
            id: id,
            startTime: entity.startDate,
            date: entity.date ?? Date(),
            duration: entity.presentation?.duration ?? entity.activity?.duration ?? entity.duration ?? 0,
            presentation: presentation,
            activity: activity
        )
    }
}
