import Fluent
import Foundation
import Vapor

final class EventDay: Model, Content, @unchecked Sendable {
    static let schema = Schema.eventDay

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "event_id")
    var event: Event
    
    @Field(key: "date")
    var date: Date
    
    @Field(key: "start_time")
    var startTime: String
    
    @Field(key: "end_time")
    var endTime: String
    
    @Field(key: "name")
    var name: String
    
    init() {}
}
