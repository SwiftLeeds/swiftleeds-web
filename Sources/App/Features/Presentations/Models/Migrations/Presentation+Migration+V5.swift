import Fluent

class PresentationMigrationV5: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .field("video_url", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .deleteField("video_url")
            .update()
    }
}
