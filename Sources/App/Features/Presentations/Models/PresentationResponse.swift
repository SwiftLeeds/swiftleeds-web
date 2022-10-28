import Foundation
import Vapor

struct PresentationResponse: Content {
    let id: UUID
    let title: String
    let synopsis: String
    let speaker: SpeakerResponse?
    let slidoURL: String?
}
