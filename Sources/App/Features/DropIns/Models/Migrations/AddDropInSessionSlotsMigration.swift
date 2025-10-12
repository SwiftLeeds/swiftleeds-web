import Fluent

final class AddDropInSessionSlotsMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.dropInSessionSlots)
            .id()
            .field("session_id", .uuid, .references(Schema.dropInSessions, "id"))
            .field("date", .datetime, .required)
            .field("ticket", .string)
            .field("ticket_owner", .string)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.dropInSessionSlots).delete()
    }
}
