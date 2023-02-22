import Fluent

class PastSponsorMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.pastSponsors)
            .id()
            .field("name", .string, .required)
            .field("image", .string, .required)
            .field("url", .string)
            .field("event_id", .uuid, .references("events", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.pastSponsors).delete()
    }
}
