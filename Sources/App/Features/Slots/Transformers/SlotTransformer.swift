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
        return .init(
            id: slot.id,
            startTime: slotDateFormatter.date(from: slot.startDate),
            duration: slot.duration,
            presentation: PresentationTransformer.transform(slot.presentation),
            activity: ActivityTransformer.transform(slot.activity)
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
