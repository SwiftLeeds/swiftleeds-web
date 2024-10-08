import Fluent
import Foundation
import Vapor

final class Activity: Codable, Model, Content, @unchecked Sendable {
    static let schema = Schema.activity

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "subtitle")
    var subtitle: String?

    @Field(key: "description")
    var description: String?

    @Field(key: "url")
    var metadataURL: String?

    @Field(key: "image")
    var image: String?
    
    @Field(key: "duration")
    var duration: Double

    @OptionalParent(key: "event_id")
    var event: Event?

    init() {}

    init(
        id: IDValue?,
        title: String,
        subtitle: String? = nil,
        description: String? = nil,
        metadataURL: String? = nil,
        image: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.metadataURL = metadataURL
        self.image = image
    }
}
