//
//  Event.swift
//  
//
//  Created by Joe Williams on 10/04/2022.
//

import Foundation
import Fluent
import Vapor

final class Event: Model, Content {
    
    typealias IDValue = UUID
    
    static let schema: String = "events"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "event_date")
    var date: Date
    
    @Field(key: "location")
    var location: String
    
    @Children(for: \.$event)
    var presentations: [Presentation]
    
    init() { }
    
    class Migrations: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(Event.schema)
                .id()
                .field("name", .string, .required)
                .field("event_date", .date, .required)
                .field("location", .string, .required)
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(Event.schema).delete()
        }
    }
}
