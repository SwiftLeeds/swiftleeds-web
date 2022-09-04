import Fluent
import Vapor

final class Token: Model, Content {
    static let schema = "tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Field(key: "debug")
    var debug: Bool

    init() {}

    init(id: UUID? = nil, token: String, debug: Bool) {
        self.id = id
        self.token = token
        self.debug = debug
    }
}
