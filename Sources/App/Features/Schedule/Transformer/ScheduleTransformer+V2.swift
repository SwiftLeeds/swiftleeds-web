import Foundation

// A unique transformer as it doesn't actually represent an entity
enum ScheduleTransformerV2 {
    static func transform(event: Event, events: [Event], slots: [Slot]) -> ScheduleResponseV2? {
        guard let eventResponse = EventTransformer.transform(event) else { return nil }

        let eventsResponse = events
            .filter { $0.date.timeIntervalSince1970 > 1420074000 } // 2015 date is used to hide unannounced events
            .compactMap { EventTransformer.transform($0) }

        return ScheduleResponseV2(
            event: eventResponse,
            events: eventsResponse,
            slots: slots.compactMap(SlotTransformerV2.transform(_:)).sorted(by: {
                if let firstDate = $0.date, let secondDate = $1.date {
                    return firstDate < secondDate
                }

                return $0.startTime < $1.startTime
            })
        )
    }
}
