import Fluent
import Foundation
import Vapor

final class Activity: Codable, Model, Content {
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

    @Parent(key: "event_id")
    var event: Event

    @OptionalParent(key: "slot_id")
    public var slot: Slot?

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
