import Fluent
import Foundation
import Vapor

final class DropInSession: Model, Content {
    typealias IDValue = UUID
    
    static var schema: String {
        return Schema.dropInSessions
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "owner")
    var owner: String
    
    @Field(key: "owner_image_url")
    var ownerImageUrl: String?
    
    @Field(key: "owner_link")
    var ownerLink: String?
    
    @Parent(key: "event_id")
    var event: Event
    
    @Children(for: \.$session)
    var slots: [DropInSessionSlot]
    
    init() {}
}
