import Foundation
import Vapor

struct PastSponsorResponse: Content {
    let id: UUID?
    let name: String
    let image: String?
    let url: String?
}
