import Fluent

final class EventDayMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.eventDay)
            .id()
            .field("event_id", .uuid, .required, .references(Schema.event, "id"))
            .field("date", .date, .required)
            .field("start_time", .string, .required)
            .field("end_time", .string, .required)
            .field("name", .string, .required)
            .create()
        
        // Custom migratory code to automatically seed the `event_days` table with previous years information
        let events = try await Event.query(on: database).all()
        let slots = try await Slot.query(on: database).with(\.$event).all()
        
        for event in events {
            print("[Migrator] Processing event: \(event.name)")
            let eventSlots = slots.filter { $0.event.id == event.id }
            let uniqueDays = Set(eventSlots.compactMap { $0.date?.withoutTime }).sorted()
            print("[Migrator] Found \(eventSlots.count) slots over \(uniqueDays.count) days")
            
            for (offset, date) in uniqueDays.enumerated() {
                let day = EventDay()
                day.id = .generateRandom()
                day.date = date
                day.name = "Day \(offset + 1)"
                day.startTime = "08:30"
                day.endTime = "22:00"
                day.$event.id = try event.requireID()
                try await day.create(on: database)
            }
        }
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.eventDay).delete()
    }
}
