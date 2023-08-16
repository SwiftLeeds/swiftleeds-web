import Fluent
import FluentPostgresDriver
import Foundation
import Vapor

final class Speaker: Codable, Model, Content {
    static let schema = Schema.speaker

    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "biography")
    var biography: String
    
    @Field(key: "profile_image")
    var profileImage: String

    @Field(key: "organisation")
    var organisation: String

    @Field(key: "twitter")
    var twitter: String?
    
    @Children(for: \.$speaker)
    var presentations: [Presentation]
    
    init() {}

    init(id: IDValue?, name: String, biography: String, profileImage: String, organisation: String, twitter: String?) {
        self.id = id
        self.name = name
        self.biography = biography
        self.profileImage = profileImage
        self.organisation = organisation
        self.twitter = twitter
    }
}
