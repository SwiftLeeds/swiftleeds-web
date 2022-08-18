import Fluent

class PresentationMigrationV2: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .field("speaker_two_id", .uuid, .references(Schema.speaker, "id", onDelete: .setNull, onUpdate: .cascade))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.activity)
            .deleteField("speaker_two_id")
            .update()
    }
}
