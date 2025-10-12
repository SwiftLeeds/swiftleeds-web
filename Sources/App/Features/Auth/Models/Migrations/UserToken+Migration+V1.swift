import Fluent

struct UserTokenMigrationV1: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.userToken)
            .id()
            .field("value", .string, .required)
            .field("timestamp", .datetime, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "value")
            .unique(on: "user_id")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.userToken).delete()
    }
}
