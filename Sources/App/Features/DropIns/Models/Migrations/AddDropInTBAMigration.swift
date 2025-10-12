import Fluent

final class AddDropInTBAMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.dropInSessions)
            .field("is_public", .bool, .sql(.default(false)), .required) // default to hidden
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.dropInSessions)
            .deleteField("is_public")
            .update()
    }
}
