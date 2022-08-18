//
//  ScheduleTransformer+V2.swift
//
//
//  Created by Alex Logan on 02/08/2022.
//

import Foundation

// A unique transformer as it doesn't actually represent an entity
enum ScheduleTransformerV2 {
    static func transform(event: Event, slots: [Slot]) -> ScheduleResponseV2? {
        guard let eventResponse = EventTransformer.transform(event) else { return nil }
        return ScheduleResponseV2(
            event: eventResponse,
            slots: slots.compactMap(SlotTransformerV2.transform(_:)).sorted(by: {
                $0.startTime < $1.startTime
            })
        )
    }
}
