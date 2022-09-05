import Fluent

class PresentationMigrationV3: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .field("slido_url", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .deleteField("slido_url")
            .update()
    }
}
