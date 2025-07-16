import Foundation
import Fluent

struct SlotMigrationV3: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.slot)
            .field("day_id", .uuid, .references(Schema.eventDay, "id"))
            .update()

        // Define a local-only model to access the old structure
        final class MigrationSlot: Model {
            static let schema = Schema.slot

            @ID(key: .id) var id: UUID?
            @Field(key: "date") var date: Date?
            @OptionalParent(key: "day_id") var day: EventDay?

            init() {}
        }

        let slots = try await MigrationSlot.query(on: database).all()
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
