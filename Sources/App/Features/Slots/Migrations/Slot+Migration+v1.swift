import Fluent

class SlotMigrationV1: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(Schema.slot)
             .id()
             .field("title", .string)
             .field("subtitle", .string)
             .field("long_description", .string)
             .field("url", .string)
             .field("start_date", .string, .required)
             .field("duration", .double)
             .field("event_id", .uuid, .required, .references(Schema.event, "id"))
             .field("presentation_id", .uuid, .references("presentations", "id"))
             .create()

        try await database.schema(Schema.presentation)
            .field("slot_id", .uuid, .references(Schema.slot, "id"))
            .update()
    }

    func revert(on database: Database) async throws {
        // remove foreign keys
        try await database
                .schema(Schema.presentation)
                .deleteField("slot_id")
                .update()
        // remove table
        try await database.schema(Schema.slot).delete()
    }
}
