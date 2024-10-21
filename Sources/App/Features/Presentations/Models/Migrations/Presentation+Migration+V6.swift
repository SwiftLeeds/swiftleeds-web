import Fluent

final class PresentationMigrationV6: AsyncMigration {
    func prepare(on database: Database) async throws {
        _ = try await database.enum("video_visibility")
            .case("unlisted")
            .case("shared")
            .case("attendee")
            .create()
        
        let videoVisibility = try await database.enum("video_visibility").read()
        
        try await database.schema(Schema.presentation)
            .field("video_visibility", videoVisibility, .sql(.default("unlisted")))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.enum("video_visibility").delete()
        
        try await database.schema(Schema.presentation)
            .deleteField("video_visibility")
            .update()
    }
}
