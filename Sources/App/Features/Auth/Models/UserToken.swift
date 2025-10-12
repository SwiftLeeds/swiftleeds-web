import Fluent
import Foundation
import Vapor

final class UserToken: Model, Content, ModelTokenAuthenticatable, Codable, @unchecked Sendable {
    static let schema = Schema.userToken
    
    typealias User = App.User
    
    static var valueKey: KeyPath<UserToken, Field<String>> { \UserToken.$value }
    static var userKey: KeyPath<UserToken, Parent<User>> { \UserToken.$user }

    var isValid: Bool {
        return timestamp > Date()
    }

    @ID()
    var id: UUID?

    @Field(key: "value")
    var value: String
    
    @Field(key: "timestamp")
    var timestamp: Date

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = .init(), value: String, timestamp: Date, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.timestamp = timestamp
        $user.id = userID
    }
}
