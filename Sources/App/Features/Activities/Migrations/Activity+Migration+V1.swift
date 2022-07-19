import Fluent

class ActivityMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.activity)
             .id()
             .field("title", .string, .required)
             .field("subtitle", .string)
             .field("description", .string)
             .field("url", .string)
             .field("image", .string)
             .field("event_id", .uuid, .references(Schema.event, "id"))
             .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.activity).delete()
    }
}
