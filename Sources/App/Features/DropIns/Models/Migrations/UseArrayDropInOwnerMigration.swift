import Fluent

final class UseArrayDropInOwnerMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        // I'll be honest, I tried so many ways to get this to be a non-breaking change... but I couldn't get it to work
        // So it's a destructive update and I've manually fixed production (James Sherlock - May 31st 2024)
        try await database.schema(Schema.dropInSessionSlots)
            .deleteField("ticket")
            .deleteField("ticket_owner")
            .field("ticket", .array(of: .string), .sql(.default("{}")), .required)
            .field("ticket_owner", .array(of: .string), .sql(.default("{}")), .required)
            .update()
    }

    func revert(on database: Database) async throws {
        // This is a breaking change
    }
}
