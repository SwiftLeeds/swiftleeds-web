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
    
    typealias IDValue = UUID
    
    static var schema: String {
        return "presentations"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "synopsis")
    var synopsis: String
    
    @Field(key: "image")
    var image: String?
    
    @Parent(key: "speaker_id")
    var speaker: Speaker
    
    @Parent(key: "event_id")
    public var event: Event
    
    init() { }
    
    init(id: IDValue?, title: String, synopsis: String, image: String?, eventID: Event.IDValue) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.image = image
        self.$event.id = eventID
    }
    
    class Migrations: AsyncMigration {
        func prepare(on database: Database) async throws {
            return try await database.schema(Presentation.schema)
                .id()
                .field("title", .string, .required)
                .field("synopsis", .string, .required)
                .field("speaker_id", .uuid, .references("speakers", "id"))
                .field("event_id", .uuid, .references("events", "id"))
                .field("image", .string)
                .create()
        }
        
        
        func revert(on database: Database) async throws {
            return try await database.schema("presentations").delete()
        }
    }
}
