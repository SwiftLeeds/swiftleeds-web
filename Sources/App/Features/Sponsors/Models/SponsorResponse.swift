import Foundation
import Vapor

struct SponsorResponse: Content {
    let id: UUID?
    let name: String
    let subtitle: String?
    let image: String?
    let url: String?
    let sponsorLevel: SponsorLevelResponse?
}

enum SponsorLevelResponse: String, Content, RawRepresentable {
    case silver
    case gold
    case platinum
}
