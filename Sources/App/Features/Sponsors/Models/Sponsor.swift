import Fluent
import Foundation
import Vapor

final class Sponsor: Model, Content {
    enum SponsorLevel: String, Codable {
        case silver
        case gold
        case platinum
    }
        
    typealias IDValue = UUID
    
    static var schema: String {
        return "sponsors"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "image")
    var image: String
    
    @Field(key: "url")
    var url: String
    
    @Enum(key: "sponsor_level")
    var sponsorLevel: SponsorLevel
    
    @Parent(key: "event_id")
    public var event: Event
    
    init() {}
    
    init(id: IDValue?, name: String, image: String, url: String, sponsorLevel: SponsorLevel) {
        self.id = id
        self.name = name
        self.image = image
        self.url = url
        self.sponsorLevel = sponsorLevel
    }
}
