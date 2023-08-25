import Foundation
import Vapor

struct PresentationResponseV2: Content {
    let id: UUID
    let title: String
    let synopsis: String
    var speakers: [SpeakerResponse] = []
    let slidoURL: String?
    let videoURL: String?
}
