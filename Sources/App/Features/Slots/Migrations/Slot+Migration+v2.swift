import Fluent

struct SlotMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database
            .schema(Schema.slot)
            .field("date", .datetime)
            .update()
    }
    
    func revert(on database: any Database) async throws {
        try await database
            .schema(Schema.slot)
            .deleteField("date")
            .update()
    }
}
