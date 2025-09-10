import Fluent

final class UserReviewMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserReview.schema)
            .id()
            .field("speaker_id", .uuid, .required, .references("speakers", "id"))
            .field("user_name", .string, .required)
            .field("user_initials", .string, .required)
            .field("rating", .int, .required)
            .field("comment", .string)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(UserReview.schema).delete()
    }
}

