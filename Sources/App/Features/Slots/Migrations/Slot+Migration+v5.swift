import Fluent
import Foundation

struct SlotMigrationV5: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.activity)
            .deleteField("slot_id")
            .update()
        
        try await database.schema(Schema.presentation)
            .deleteField("slot_id")
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Schema.presentation)
            .field("slot_id", .uuid, .references(Schema.slot, "id", onDelete: .setNull, onUpdate: .cascade))
            .unique(on: "slot_id")
            .update()
        
        try await database.schema(Schema.activity)
            .field("slot_id", .uuid, .references(Schema.slot, "id", onDelete: .setNull, onUpdate: .cascade))
            .unique(on: "slot_id")
            .update()
    }
}
