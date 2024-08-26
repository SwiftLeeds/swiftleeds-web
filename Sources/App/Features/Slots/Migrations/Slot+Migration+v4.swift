import Foundation
import Fluent

struct SlotMigrationV4: AsyncMigration {
    func prepare(on database: Database) async throws {
        fatalError("Read comment from Aug 2024 below")
        // Aug 2024: This migrator has been partially commented out as the field it relies on has been removed (as it was no longer needed).
        // In order to migrate past this point, you need to go to an earlier commit, migrate, and then come to a more recent commit before finishing
        // the migration.
        // Or, alternatively, just take a backup of production and apply that locally so you're up to date without playing git games.
        
        /*
        try await database.schema(Schema.slot)
            .field("presentation_id", .uuid, .references(Schema.presentation, "id"))
            .field("activity_id", .uuid, .references(Schema.activity, "id"))
            .update()
        
        try await database.schema(Schema.activity)
            .field("duration", .double, .sql(.default(0)))
            .update()
        
        try await database.schema(Schema.presentation)
            .field("duration", .double, .sql(.default(0)))
            .update()
        
        // Data Migrator
        
        let slots = try await Slot.query(on: database).all()
        let presentations = try await Presentation.query(on: database).with(\.$slot).all()
        let activities = try await Activity.query(on: database).with(\.$slot).all()
        
        for presentation in presentations {
            if let slot = slots.first(where: { $0.id == presentation.slot?.id }) {
                let slotDuration = slot.duration
                slot.$presentation.id = try presentation.requireID()
                slot.duration = 0 // easy to set to nil in future cleanup
                try await slot.update(on: database)
                
                presentation.$slot.id = nil
                presentation.duration = slotDuration ?? 0
                try await presentation.update(on: database)
            }
        }
        
        for activity in activities {
            if let slot = slots.first(where: { $0.id == activity.slot?.id }) {
                let slotDuration = slot.duration
                slot.$activity.id = try activity.requireID()
                slot.duration = 0 // easy to set to nil in future cleanup
                try await slot.update(on: database)
                
                activity.$slot.id = nil
                activity.duration = slotDuration ?? 0
                try await activity.update(on: database)
            }
        }
        */
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Schema.slot)
            .deleteField("presentation_id")
            .deleteField("activity_id")
            .update()
        
        try await database.schema(Schema.activity)
            .deleteField("duration")
            .update()
        
        try await database.schema(Schema.presentation)
            .deleteField("duration")
            .update()
    }
}
