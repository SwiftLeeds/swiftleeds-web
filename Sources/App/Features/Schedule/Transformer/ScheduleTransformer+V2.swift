import Foundation

// A unique transformer as it doesn't actually represent an entity
enum ScheduleTransformerV2 {
    static func transform(event: Event, slots: [Slot]) -> ScheduleResponseV2? {
        guard let eventResponse = EventTransformer.transform(event) else { return nil }

        return ScheduleResponseV2(
            event: eventResponse,
            slots: slots.compactMap(SlotTransformerV2.transform(_:)).sorted(by: {
                if let firstDate = $0.date, let secondDate = $1.date {
                    return firstDate < secondDate
                }

                return $0.startTime < $1.startTime
            })
        )
    }
}
