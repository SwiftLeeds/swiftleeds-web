import Foundation
import Vapor

struct ScheduleResponse: Content {
    let event: EventResponse
    let events: [EventResponse]
    let slots: [SlotResponse]
}
