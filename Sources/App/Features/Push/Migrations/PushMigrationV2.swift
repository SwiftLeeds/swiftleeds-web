import Fluent

struct PushMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.tokens)
            .field("updated_at", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.tokens)
            .deleteField("updated_at")
            .update()
    }
}
