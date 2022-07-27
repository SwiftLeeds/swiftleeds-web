//
//  SlotTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum SlotTransformer: Transformer {
    static func transform(_ entity: Slot?) -> SlotResponse? {
        guard let slot = entity else {
            return nil
        }

        let presentation: PresentationResponse?
        let activity: ActivityResponse?

        if let presentationEntity = slot.$presentation.value {
            presentation = PresentationTransformer.transform(presentationEntity)
        } else {
            presentation = nil
        }

        if let activityEntity = slot.$activity.value {
            activity = ActivityTransformer.transform(activityEntity)
        } else {
            activity = nil
        }

        return .init(
            id: slot.id,
            startTime: slotDateFormatter.date(from: slot.startDate),
            duration: slot.duration,
            presentation: presentation,
            activity: activity
        )
    }
}

private extension SlotTransformer {
    private static var slotDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}
