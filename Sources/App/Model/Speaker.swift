//
//  Speaker.swift
//  
//
//  Created by Joe Williams on 09/04/2022.
//

import Foundation
import Vapor
import Fluent

final class Speaker: Codable, Model, Content {

    typealias IDValue = UUID
    
    static var schema: String {
        return "speakers"
    }
    
    @ID()
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "biography")
    var biography: String
    
    @Field(key: "profile_image")
    var profileImage: String
    
    @Field(key: "twitter")
    var twitter: String?
    
    @OptionalChild(for: \.$speaker)
    var presentation: Presentation?
    
    init() {
        
    }
    
    init(id: UUID? = .init(),
         name: String,
         biography: String,
         profileImage: String = "avatar.png",
         twitter: String?
    ) {
        
        self.name = name
        self.biography = biography
        self.profileImage = profileImage
        self.twitter = twitter
    }
    
    struct Migrations: AsyncMigration {
        
        var name: String {
            "CreateSpeakerMigration"
        }
        
        func prepare(on database: Database) async throws {
            try await database.schema(Speaker.schema)
                .field("id", .uuid, .identifier(auto: true))
                .field("name", .string, .required)
                .field("biography", .string, .required)
                .field("twitter", .string)
                .field("profile_image", .string, .sql(.default("avatar.png")))
                .unique(on: "name")
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(Speaker.schema).delete()
        }
    }
}
