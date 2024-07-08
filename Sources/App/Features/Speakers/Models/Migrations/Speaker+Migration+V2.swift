import Fluent

final class SpeakerMigrationV2: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.speaker)
            .field("linkedin", .string)
            .field("website", .string)
            .field("github", .string)
            .field("mastodon", .string)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.speaker)
            .deleteField("linkedin")
            .deleteField("website")
            .deleteField("github")
            .deleteField("mastodon")
            .delete()
    }
}
