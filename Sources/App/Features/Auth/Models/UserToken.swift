//
//  File.swift
//  
//
//  Created by Joe Williams on 14/11/2021.
//

import Foundation
import Vapor
import Fluent

final class UserToken: Model, Content, ModelTokenAuthenticatable, Codable {
    typealias User = App.User
    
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    static let schema = "user_tokens"
    
    var isValid: Bool {
        return self.timestamp > Date()
    }

    @ID()
    var id: UUID?

    @Field(key: "value")
    var value: String
    
    @Field(key: "timestamp")
    var timestamp: Date

    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = .init(), value: String, timestamp: Date, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
        self.$user.id = userID
    }
    
    struct Migrations: AsyncMigration {
        func prepare(on database: Database) async throws {
            return try await database.schema("user_tokens")
                .id()
                .field("value", .string, .required)
                .field("timestamp", .datetime, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "value")
                .unique(on: "user_id")
                .create()
        }

        func revert(on database: Database) async throws {
            return try await database.schema("user_tokens").delete()
        }
    }
}
