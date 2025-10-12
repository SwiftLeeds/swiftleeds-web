import Fluent

final class UserMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.user)
            .field("permissions", .array(of: .string), .required, .sql(.default("{}")))
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.user)
            .deleteField("permissions")
            .update()
    }
}
