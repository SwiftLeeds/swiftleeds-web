import Fluent

class SponsorMigrationV2: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.sponsor)
            .field("subtitle", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.sponsor)
            .deleteField("subtitle")
            .update()
    }
}
