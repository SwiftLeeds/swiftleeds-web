import Fluent
import Foundation
import Vapor

final class Location: Codable, Model, Content {
    static let schema = Schema.location

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "lat")
    var lat: Double

    @Field(key: "lon")
    var lon: Double

    @Field(key: "url")
    var url: String

    @Parent(key: "category_id")
    var category: LocationCategory
}
