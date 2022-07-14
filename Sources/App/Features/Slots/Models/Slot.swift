import Foundation
import Fluent
import Vapor

final class Slot: Model, Content {

    static let schema = Schema.slot

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    // Optional metadata for a slot to have its own context
    @Field(key: "title")
    var title: String?

    @Field(key: "subtitle")
    var subtitle: String?

    @Field(key: "long_description")
    var longDescription: String?

    // If this slot needs additional information, it can link out to something else
    @Field(key: "url")
    var metadataURL: String?

    @Field(key: "start_date")
    var startDate: String

    @Field(key: "duration")
    var duration: Double

    @Parent(key: "event_id")
    var event: Event

    @Children(for: \.$slot)
    var presentation: [Presentation]

    init() { }

    init(
        id: IDValue?,
        title: String? = nil,
        subtitle: String? = nil,
        longDescription: String? = nil,
        metadataURL: String? = nil,
        startDate: String,
        duration: Double
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.longDescription = longDescription
        self.metadataURL = metadataURL
        self.startDate = startDate
        self.duration = duration
    }
}
