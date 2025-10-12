import Fluent

final class SponsorMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.sponsor)
            .field("subtitle", .string)
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.sponsor)
            .deleteField("subtitle")
            .update()
    }
}
