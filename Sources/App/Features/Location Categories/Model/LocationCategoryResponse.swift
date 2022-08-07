import Foundation
import Vapor

struct LocationCategoryResponse: Codable, Content {
    var id: UUID
    var name: String
    var symbolName: String
    var locations: [LocationResponse]
}
