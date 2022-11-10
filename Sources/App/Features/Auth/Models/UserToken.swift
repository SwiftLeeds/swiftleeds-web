import Fluent
import Foundation
import Vapor

final class UserToken: Model, Content, ModelTokenAuthenticatable, Codable {
    static let schema = Schema.userToken
    
    typealias User = App.User
    
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user

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
