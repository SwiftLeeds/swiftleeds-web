import Fluent
import Foundation
import Vapor

final class LastUpdated: Model {
    typealias IDValue = UUID

    static var schema: String {
        return "last_updated"
    }

    @ID(key: .id)
    var id: UUID?

    @Field(key: "sponsors")
    var sponsors: Date

    @Field(key: "presentations")
    var presentations: Date

    @Field(key: "activities")
    var activities: Date

    @Field(key: "speakers")
    var speakers: Date

    @Field(key: "slots")
    var slots: Date

    @Field(key: "events")
    var events: Date

    init() {}

    init(id: IDValue?, sponsors: Date, presentations: Date, activities: Date, speakers: Date, slots: Date, events: Date) {
        self.id = id
        self.sponsors = sponsors
        self.presentations = presentations
        self.activities = activities
        self.speakers = speakers
        self.slots = slots
        self.events = events
    }
}
