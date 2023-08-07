import Fluent

class LastUpdatedMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.lastUpdated)
            .id()
            .field("sponsors", .datetime, .required)
            .field("presentations", .datetime, .required)
            .field("activities", .datetime, .required)
            .field("speakers", .datetime, .required)
            .field("slots", .datetime, .required)
            .field("events", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.lastUpdated).delete()
    }
}
