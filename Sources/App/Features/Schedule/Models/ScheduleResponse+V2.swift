import Foundation
import Vapor

struct ScheduleResponseV2: Content {
    let event: EventResponse
    let events: [EventResponse]
    let days: [DayResponse]
    
    struct DayResponse: Codable {
        let name: String
        let date: Date
        let slots: [SlotResponse]
    }
}
