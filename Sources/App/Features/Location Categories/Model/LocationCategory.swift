import Foundation
import Fluent
import Vapor

final class LocationCategory: Codable, Model, Content {

    static let schema = Schema.locationCategory

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "symbol_name")
    var symbolName: String

    @Children(for: \.$category)
    var locations: [Location]

    init() { }
}
