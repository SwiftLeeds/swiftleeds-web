//
//  File.swift
//  
//
//  Created by Joe Williams on 14/11/2021.
//

import Foundation
import Vapor
import Fluent

final class AppUser: Model, ModelAuthenticatable, Content {
    
    enum UserRole: String, Codable {
        case user, editor, admin
    }
    
    static let usernameKey = \AppUser.$email
    static let passwordHashKey = \AppUser.$passwordHash
    static let schema = "app_users"
    
    // Unique identifier for this user.
    @ID(key: .id)
    var id: UUID?

    // The user's name.
    @Field(key: "name")
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "user_role")
    var role: UserRole
    
    // Creates a new, empty user.
    init() { }

    // Creates a new user with all properties set.
    init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: UserRole) {
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
    
    class Migrations: Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(AppUser.schema)
                .id()
                .field("name", .string, .required)
                .field("password_hash", .string, .required)
                .field("email", .string, .required)
                .field("user_role", .string, .sql(.default("user")))
                .unique(on: "email")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            return database.schema(AppUser.schema).delete()
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

class AdminAuthenticatable: BearerAuthenticator {
    
    enum RoleFailure: Error {
        case notAuthenticated
        case notAdmin
    }
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        UserToken.query(on: request.db)
            .filter(\.$value == bearer.token)
            .first()
            .flatMap { token in
                guard let token = token else {
                    throw Abort(.unauthorized)
                }
                guard token.isValid else {
                    return token.delete(on: request.db)
                }
                
                return token.$user.get(on: request.db).flatMapThrowing { user in
                    guard user.role == .admin else {
                        throw Abort(.unauthorized)
                    }
                    request.auth.login(token)
                    request.auth.login(user)
                }
            }
    }
}
