import Fluent

class SponsorMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database.enum("sponsor_level")
            .case("silver")
            .case("gold")
            .case("platinum")
            .create()
        
        let sponsorLevel = try await database.enum("sponsor_level").read()
        
        try await database.schema(Schema.sponsor)
            .id()
            .field("name", .string, .required)
            .field("image", .string, .required)
            .field("url", .string)
            .field("sponsor_level", sponsorLevel, .required)
            .field("event_id", .uuid, .references("events", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.enum("sponsor_level").delete()
        try await database.schema(Schema.sponsor).delete()
    }
}
