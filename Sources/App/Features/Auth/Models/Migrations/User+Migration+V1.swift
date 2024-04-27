import Fluent

final class UserMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.user)
            .id()
            .field("name", .string, .required)
            .field("password_hash", .string, .required)
            .field("email", .string, .required)
            .field("user_role", .string, .sql(.default("user")))
            .unique(on: "email")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.user).delete()
    }
}
