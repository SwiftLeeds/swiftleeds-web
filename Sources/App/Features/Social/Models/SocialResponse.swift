import Foundation
import Vapor

struct SocialResponse: Content {
    let socialLinks: [SocialLink]
}

struct SocialLink: Content {
    let id: String
    let name: String
    let url: String
    let icon: String
    let displayName: String?
    let order: Int
}
