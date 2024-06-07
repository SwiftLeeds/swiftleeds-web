import Fluent

final class AddDurationToDropInMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.dropInSessionSlots)
            .field("duration", .int, .sql(.default(15)), .required)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.dropInSessionSlots)
            .deleteField("duration")
            .update()
    }
}
