import Fluent

final class SlotMigrationV1: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.slot)
            .id()
            .field("start_date", .string, .required)
            .field("duration", .double)
            .field("event_id", .uuid, .required, .references(Schema.event, "id"))
            .create()

        // Insert the slot relation into child entities
        try await database.schema(Schema.presentation)
            .field("slot_id", .uuid, .references(Schema.slot, "id", onDelete: .setNull, onUpdate: .cascade))
            .unique(on: "slot_id")
            .update()

        try await database.schema(Schema.activity)
            .field("slot_id", .uuid, .references(Schema.slot, "id", onDelete: .setNull, onUpdate: .cascade))
            .unique(on: "slot_id")
            .update()

        // Due to the lack of slots when initially created, presentations need to be "upgraded"
        // We need to get every presentation, check if it has a slot_id or not, and then create the correct slot
        // TODO: What i describe above

        // Remove the legacy fields as they're no longer required
        try await database
            .schema(Schema.presentation)
            .deleteField("start_date")
            .deleteField("duration")
            .update()
    }

    func revert(on database: any Database) async throws {
        // remove foreign keys & restore deleted fields
        try await database
            .schema(Schema.presentation)
            .deleteField("slot_id")
            .field("start_date", .string)
            .field("duration", .double)
            .update()

        try await database.schema(Schema.activity)
            .deleteField("slot_id")
            .update()

        // remove table
        try await database.schema(Schema.slot).delete()
    }
}
