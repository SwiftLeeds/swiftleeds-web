import Fluent

final class AddDropInGroupsMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.dropInSessions)
            .field("max_tickets", .int, .sql(.default(1)), .required)
            .field("exclusivity_key", .string, .sql(.default("A")), .required)
            .field("company", .string)
            .field("company_image_url", .string)
            .field("company_link", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.dropInSessions)
            .deleteField("max_tickets")
            .deleteField("exclusivity_key")
            .deleteField("company")
            .deleteField("company_image_url")
            .deleteField("company_link")
            .update()
    }
}
