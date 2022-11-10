import Fluent

class PresentationMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.presentation)
            .id()
            .field("title", .string, .required)
            .field("synopsis", .string)
            .field("speaker_id", .uuid, .references("speakers", "id"))
            .field("event_id", .uuid, .references("events", "id"))
            .field("image", .string)
            .field("start_date", .string)
            .field("duration", .double)
            .field("is_tba", .bool)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.presentation).delete()
    }
}
