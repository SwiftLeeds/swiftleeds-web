import Foundation
import Vapor

struct TeamResponse: Content {
    let teamMembers: [TeamMember]
}

struct TeamMember: Content {
    let name: String
    let role: String?
    let twitter: String?
    let linkedin: String?
    let slack: String?
    let imageURL: String
    let core: Bool
}
