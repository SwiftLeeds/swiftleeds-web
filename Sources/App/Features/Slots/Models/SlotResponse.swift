import Foundation
import Vapor

struct SlotResponse: Content {
    let id: UUID
    let startTime: String
    let date: Date
    let duration: Double
    let presentation: PresentationResponse?
    let activity: ActivityResponse?
}
