import Fluent
import Foundation
import Vapor

final class Job: Model, Content {
    typealias IDValue = UUID

    static let schema: String = "jobs"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "location")
    var location: String

    @Field(key: "details")
    var details: String

    @Field(key: "url")
    var url: String

    @Parent(key: "sponsor_id")
    var sponsor: Sponsor

    init() {}

    init(id: IDValue?, title: String, location: String, details: String, url: String) {
        self.id = id
        self.title = title
        self.location = location
        self.details = details
        self.url = url
    }
}
