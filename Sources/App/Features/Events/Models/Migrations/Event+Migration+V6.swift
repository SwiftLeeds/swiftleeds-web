import Fluent

final class EventMigrationV6: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .field("conference", .string, .required, .sql(.default("swiftleeds")))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.event)
            .deleteField("conference")
            .update()
    }
}
