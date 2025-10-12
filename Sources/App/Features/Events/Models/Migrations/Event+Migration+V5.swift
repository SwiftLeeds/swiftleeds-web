import Fluent

final class EventMigrationV5: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .field("checkin_key", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .deleteField("checkin_key")
            .update()
    }
}
