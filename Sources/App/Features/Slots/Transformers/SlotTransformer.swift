//
//  SlotTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum SlotTransformer: Transformer {
    static func transform(_ entity: Slot?) -> SlotResponse? {
        guard let entity = entity, let id = entity.id else { return nil }

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
            duration: entity.duration,
            presentation: presentation,
            activity: activity
        )
    }
}
