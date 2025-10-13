import Fluent
import Foundation
import Vapor

final class User: Authenticatable, ModelAuthenticatable, Content, ModelSessionAuthenticatable, ModelCredentialsAuthenticatable, Codable, @unchecked Sendable {
    static let schema = Schema.user
    
    enum Role: String, Codable {
        case user
        case speaker
        case admin
    }
    
    var sessionID: UUID {
        return id ?? .init()
    }
    
    static var usernameKey: KeyPath<User, Field<String>> { \User.$email }
    static var passwordHashKey: KeyPath<User, Field<String>> { \User.$passwordHash }
    
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
    
    @Field(key: "permissions")
    var permissions: [String]
    
    @Field(key: "user_role")
    var role: User.Role
    
    @OptionalChild(for: \.$user)
    var token: UserToken?
    
    // Creates a new, empty user.
    init() {}

    // Creates a new user with all properties set.
    init(id: UUID? = .init(), name: String, email: String, passwordHash: String, role: User.Role) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
    }
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
    
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            timestamp: Date().addingTimeInterval(604800), // token is valid for 1 week
            userID: requireID()
        )
    }
    
    static func credentialsAuthenticator(
        database _: DatabaseID? = nil
    ) -> any Authenticator {
        return CustomCredentialsAuthenticator()
    }
    
    static func sessionAuthenticator(
        _: DatabaseID? = nil
    ) -> any Authenticator {
        return SessionAuthenticator()
    }
    
    static func authenticator(
        database _: DatabaseID? = nil
    ) -> any Authenticator {
        return BearerAuthenticatable()
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
