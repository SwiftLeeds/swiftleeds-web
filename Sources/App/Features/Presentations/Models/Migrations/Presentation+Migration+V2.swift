import Fluent

final class PresentationMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.presentation)
            .field("speaker_two_id", .uuid, .references(Schema.speaker, "id", onDelete: .setNull, onUpdate: .cascade))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.presentation)
            .deleteField("speaker_two_id")
            .update()
    }
}
