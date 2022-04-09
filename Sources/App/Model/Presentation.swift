//
//  Presentation.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor
import Fluent

final class Presentation: Codable, Model, Content {
    
    static var schema: String {
        return "presentations"
    }
    
    @ID(custom: "id", generatedBy: .database)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "synopsis")
    var synopsis: String
    
    @Field(key: "image")
    var image: String?
    
    @Parent(key: "speaker_id")
    var speaker: Speaker
    
    init() { }
    
    init(id: UUID? = .init(), title: String, synopsis: String, image: String?, speakerID: Speaker.IDValue) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.image = image
        self.$speaker.id = speakerID
    }
    
    struct Migrations: AsyncMigration {
        var name: String {
            "CreatePresentationMigration"
        }
        
        func prepare(on database: Database) async throws {
            return try await database.schema(Presentation.schema)
                .id()
                .field("title", .string, .required)
                .field("synopsis", .string, .required)
                .field("speaker_id", .uuid, .references("speakers", "id"))
                .unique(on: "speaker_id")
                .create()
        }
        
        
        func revert(on database: Database) async throws {
            return try await database.schema("presentations").delete()
        }
    }
}
