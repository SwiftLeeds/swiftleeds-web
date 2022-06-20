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
        var name: String {
            "speakerv2"
        }

        func prepare(on database: Database) async throws {
            
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(Speaker.schema).delete()
        }
    }
}
