import Foundation
import Vapor

struct SpeakerResponse: Content {
    let id: UUID?
    let name: String
    let biography: String
    let profileImage: String
    let twitter: String?
    let organisation: String
    let presentations: [PresentationResponse]?
}
