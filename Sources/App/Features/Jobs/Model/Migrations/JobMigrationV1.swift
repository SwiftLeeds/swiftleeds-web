import Fluent

class JobMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.job)
            .id()
            .field("title", .string, .required)
            .field("location", .string, .required)
            .field("details", .string, .required)
            .field("url", .string, .required)
            .field("sponsor_id", .uuid, .references(Schema.sponsor, "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.job).delete()
    }
}
