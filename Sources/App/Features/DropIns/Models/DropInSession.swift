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
    
    // The total number of people who can have a ticket for a single slot
    @Field(key: "max_tickets")
    var maxTicketsPerSlot: Int
    
    // The total number of tickets a single attendee can have (one per key)
    @Field(key: "exclusivity_key")
    var exclusivityKey: String
    
    // Owner presents the individual who is running the drop-in session
    @Field(key: "owner")
    var owner: String
    
    @Field(key: "owner_image_url")
    var ownerImageUrl: String?
    
    @Field(key: "owner_link")
    var ownerLink: String?
    
    // Company is for drop-in sessions which relate to a branded product (it may or may not be sponsored)
    @Field(key: "company")
    var company: String?
    
    @Field(key: "company_image_url")
    var companyImageUrl: String?
    
    @Field(key: "company_link")
    var companyLink: String?
    
    @Field(key: "is_public")
    var isPublic: Bool
    
    @Parent(key: "event_id")
    public var event: Event
    
    @Children(for: \.$session)
    var slots: [DropInSessionSlot]
    
    init() {}
}
