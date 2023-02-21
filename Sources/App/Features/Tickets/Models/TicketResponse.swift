import Foundation
import Vapor

struct TicketResponse: Content {
    let firstName: String
    let lastName: String
    let company: String?
    let avatarUrl: URL?
    let responses: [String: String]?
}
