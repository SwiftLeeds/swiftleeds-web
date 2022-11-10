import Foundation
import Vapor

struct SlotResponse: Content {
    let id: UUID
    let startTime: String
    let duration: Double
    let presentation: PresentationResponse?
    let activity: ActivityResponse?
}
