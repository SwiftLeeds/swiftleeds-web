import Fluent
import Foundation
import Vapor

final class DropInSessionSlot: Model, Content, @unchecked Sendable {
    typealias IDValue = UUID
    
    static var schema: String {
        return Schema.dropInSessionSlots
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "date")
    var date: Date
    
    @Field(key: "ticket")
    var ticket: [String]
    
    @Field(key: "ticket_owner")
    var ticketOwner: [String]
    
    @Field(key: "duration")
    var duration: Int // in minutes
    
    @Parent(key: "session_id")
    public var session: DropInSession
    
    init() {}
}
