import Foundation
import Vapor

struct ScheduleResponse: Content {
    let event: EventResponse
    let slots: [SlotResponse]
}
