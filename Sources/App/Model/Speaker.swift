//
//  Speaker.swift
//  
//
//  Created by Joe Williams on 09/04/2022.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Speaker: Codable, Model, Content {

    typealias IDValue = UUID
    
    static var schema: String {
        return "speakers"
    }
    
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
    
    init() { }
    
    class Migrations: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(Speaker.schema)
                .id()
                .field("name", .string, .required)
                .field("biography", .string, .required)
                .field("twitter", .string)
                .field("organisation", .string, .required)
                .field("profile_image", .string, .sql(.default("avatar.png")))
                .unique(on: "name")
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(Speaker.schema).delete()
        }
    }
}
