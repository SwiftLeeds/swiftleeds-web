import Fluent

class PresentationMigrationV4: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .deleteField("image")
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .field("image", .string)
            .update()
    }
}
