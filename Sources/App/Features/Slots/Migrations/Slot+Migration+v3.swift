import Foundation
import Fluent

struct SlotMigrationV3: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.slot)
            .field("day_id", .uuid, .references(Schema.eventDay, "id"))
            .update()
        
        let slots = try await Slot.query(on: database).all()
        let days = try await EventDay.query(on: database).all()
        
        for slot in slots {
            if let day = days.first(where: { $0.date.withoutTime == slot.date?.withoutTime }) {
                slot.$day.id = try day.requireID()
                try await slot.update(on: database)
            } else {
                print("[Migrator] Unable to find EventDay for Slot")
            }
        }
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Schema.slot)
            .deleteField("day_id")
            .update()
    }
}
