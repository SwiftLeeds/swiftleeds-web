import Fluent

final class AddDropInSessionMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.dropInSessions)
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("owner", .string, .required)
            .field("owner_image_url", .string)
            .field("owner_link", .string)
            .field("event_id", .uuid, .references("events", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.dropInSessions).delete()
    }
}
