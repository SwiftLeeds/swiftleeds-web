import Fluent
import Foundation
import Vapor

final class Sponsor: Model, Content {
    static let schema = Schema.sponsor

    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String

    @Field(key: "subtitle")
    var subtitle: String?

    @Field(key: "image")
    var image: String
    
    @Field(key: "url")
    var url: String
    
    @Enum(key: "sponsor_level")
    var sponsorLevel: SponsorLevel
    
    @Parent(key: "event_id")
    public var event: Event

    @Children(for: \.$sponsor)
    var jobs: [Job]
    
    init() {}
    
    init(id: IDValue?, name: String, subtitle: String?, image: String, url: String, sponsorLevel: SponsorLevel) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.image = image
        self.url = url
        self.sponsorLevel = sponsorLevel
    }

    // MARK: - SponsorLevel
    enum SponsorLevel: String, Codable {
        case silver
        case gold
        case platinum
    }
}
