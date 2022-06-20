//
//  Presentation.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor
import Fluent

final class Presentation: Model, Content {
        
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
    
    @Field(key: "start_date")
    var startDate: String
    
    @Field(key: "duration")
    var duration: Double
    
    @Field(key: "is_tba")
    var isTBA: Bool
    
    init() { }
    
    init(id: IDValue?, title: String, synopsis: String, image: String?, startDate: String, duration: Double, isTBA: Bool) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.image = image
        self.startDate = startDate
        self.duration = duration
        self.isTBA = isTBA
    }
    
    class Migrations: AsyncMigration {
        
        var name: String {
            "presentationsv2.1"
        }
        
        func prepare(on database: Database) async throws {
            let schema = try await database.schema(Presentation.schema)
                .field("start_date", .string)
                .field("duration", .double)
                .field("is_tba", .bool)
            
            try await schema.update()
        }

        func revert(on database: Database) async throws {
            return try await database.schema("presentations").delete()
        }
    }
}
