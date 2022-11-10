import Foundation
import Vapor

struct EventResponse: Content {
    var id: UUID
    var name: String
    var date: String
    var location: String
}
