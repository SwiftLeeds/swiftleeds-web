import Fluent

struct SlotMigrationV2: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database
            .schema(Schema.slot)
            .field("date", .datetime)
            .update()
    }
    
    func revert(on database: Database) async throws {
        try await database
            .schema(Schema.slot)
            .deleteField("date")
            .update()
    }
}
