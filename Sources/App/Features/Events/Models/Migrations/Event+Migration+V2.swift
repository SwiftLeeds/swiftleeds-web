import Fluent

class EventMigrationV2: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.event)
            .field("is_current", .bool, .sql(.default(false)), .required)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.event)
            .deleteField("is_current")
            .update()
    }
}
