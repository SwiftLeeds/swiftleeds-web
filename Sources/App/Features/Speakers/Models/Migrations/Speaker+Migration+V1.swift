import Fluent

class SpeakerMigrationV1: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(Speaker.schema)
             .id()
             .field("name", .string, .required)
             .field("biography", .string, .required)
             .field("twitter", .string)
             .field("organisation", .string, .required)
             .field("profile_image", .string, .sql(.default("avatar.png")))
             .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.speaker).delete()
    }
}
