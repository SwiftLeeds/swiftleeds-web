import Fluent
import Vapor

final class Token: Model, Content, @unchecked Sendable {
    static let schema = "tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Field(key: "debug")
    var debug: Bool

    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, token: String, debug: Bool) {
        self.id = id
        self.token = token
        self.debug = debug
    }
}
