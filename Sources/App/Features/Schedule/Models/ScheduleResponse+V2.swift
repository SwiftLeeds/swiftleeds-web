import Foundation
import Vapor

struct ScheduleResponseV2: Content {
    let event: EventResponse
    let events: [EventResponse]
    let slots: [SlotResponseV2]
}
