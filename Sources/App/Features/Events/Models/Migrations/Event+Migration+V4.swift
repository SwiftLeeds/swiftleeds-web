import Fluent

final class EventMigrationV4: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .field("sessionize_key", .string)
            .field("show_schedule", .bool, .sql(.default(false)), .required)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .deleteField("sessionize_key")
            .deleteField("show_schedule")
            .update()
    }
}
