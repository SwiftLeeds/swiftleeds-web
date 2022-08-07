import Foundation
import Vapor

struct LocationResponse: Codable, Content {
    var id: UUID
    var name: String
    var lat: Double
    var lon: Double
    var url: String
}
