import Foundation
import Fluent
import Vapor

final class Slot: Codable, Model, Content {

    static let schema = Schema.slot

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "start_date")
    var startDate: String

    @Field(key: "duration")
    var duration: Double

    @Parent(key: "event_id")
    var event: Event

    @OptionalChild(for: \.$slot)
    var presentation: Presentation?

    @OptionalChild(for: \.$slot)
    var activity: Activity?

    init() { }

    init(
        id: IDValue?,
        startDate: String,
        duration: Double
    ) {
        self.id = id
        self.startDate = startDate
        self.duration = duration
    }
}
