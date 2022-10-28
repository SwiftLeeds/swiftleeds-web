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
    
    @Field(key: "twitter")
    var twitter: String?
    
    @Field(key: "organisation")
    var organisation: String
    
    @Children(for: \.$speaker)
    var presentations: [Presentation]
    
    init() {}
}
