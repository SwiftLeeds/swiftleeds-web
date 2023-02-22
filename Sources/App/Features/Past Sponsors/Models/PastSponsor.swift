import Fluent
import Foundation
import Vapor

final class PastSponsor: Model, Content {        
    typealias IDValue = UUID
    
    static let schema = Schema.pastSponsors
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "url")
    var url: String
    
    @Parent(key: "event_id")
    public var event: Event
    
    init() {}
    
    init(id: IDValue?, name: String, image: String, url: String) {
        self.id = id
        self.name = name
        self.image = image
        self.url = url
    }
}
