import Fluent
import Foundation

struct SlotMigrationV6: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(Schema.slot)
            .deleteField("date")
            .deleteField("event_id")
            .update()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(Schema.slot)
            .field("date", .datetime)
            .field("event_id", .uuid, .references(Schema.event, "id"))
            .update()
    }
}
