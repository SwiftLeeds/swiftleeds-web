import Fluent

struct PushMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.tokens)
            .id()
            .field("token", .string, .required)
            .field("debug", .bool, .required)
            .unique(on: "token")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.tokens).delete()
    }
}
