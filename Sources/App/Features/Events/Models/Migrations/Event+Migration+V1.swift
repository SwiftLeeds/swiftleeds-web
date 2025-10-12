import Fluent

final class EventMigrationV1: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .id()
            .field("name", .string, .required)
            .field("event_date", .date, .required)
            .field("location", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.event).delete()
    }
}
