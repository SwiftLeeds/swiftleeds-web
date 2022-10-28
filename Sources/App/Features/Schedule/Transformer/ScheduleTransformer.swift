import Foundation

// A unique transformer as it doesn't actually represent an entity
enum ScheduleTransformer {
    static func transform(event: Event, slots: [Slot]) -> ScheduleResponse? {
        guard let eventResponse = EventTransformer.transform(event) else {
            return nil
        }
        return ScheduleResponse(
            event: eventResponse,
            slots: slots.compactMap(SlotTransformer.transform(_:)).sorted(by: {
                $0.startTime < $1.startTime
            })
        )
    }
}
