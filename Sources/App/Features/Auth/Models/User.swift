//
//  User.swift
//  
//
//  Created by Joe Williams on 14/11/2021.
//

import Foundation
import Vapor
import Fluent

final class User: Authenticatable, ModelAuthenticatable, Content, ModelSessionAuthenticatable, ModelCredentialsAuthenticatable, Codable {
    enum Role: String, Codable {
        case user, speaker, admin
    }
    
    var sessionID: UUID {
        return id ?? .init()
    }
    
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash
    static let schema = "users"
    
    // Unique identifier for this user.
    @ID()
    var id: UUID?

    // The user's name.
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "user_role")
    var role: User.Role
    
    @OptionalChild(for: \.$user)
    var token: UserToken?
    
    // Creates a new, empty user.
    init() { }

    // Creates a new user with all properties set.
    init(id: UUID? = .init(), name: String, email: String, passwordHash: String, role: User.Role) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            timestamp: Date().addingTimeInterval(604800), // token is valid for 1 week
            userID: self.requireID()
        )
    }
    
    public static func credentialsAuthenticator(
        database: DatabaseID? = nil
    ) -> Authenticator {
        return CustomCredentialsAuthenticator()
    }
    
    public static func sessionAuthenticator(
        _ databaseID: DatabaseID? = nil
    ) -> Authenticator {
        return SessionAuthenticator()
    }
    
    public static func authenticator(
        database: DatabaseID? = nil
    ) -> Authenticator {
        return BearerAuthenticatable()
    }
    
    class Migrations: AsyncMigration {
        var name: String {
            "userv2.1"
        }
        func prepare(on database: Database) async throws {

        }

        func revert(on database: Database) async throws {
            try await database.schema(User.schema).delete()
        }
    }

    struct Create: Content, Validatable {
        var name: String
        var email: String
        var password: String
        var confirmPassword: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty)
            validations.add("email", as: String.self, is: .email)
            validations.add("password", as: String.self, is: .count(8...))
        }
    }
}
