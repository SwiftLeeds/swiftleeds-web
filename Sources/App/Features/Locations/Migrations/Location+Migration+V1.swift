import Fluent
import Foundation
import Vapor

final class LocationMigrationV1: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.location)
            .id()
            .field("name", .string, .required)
            .field("url", .string, .required)
            .field("lat", .double, .required)
            .field("lon", .double, .required)
            .field("category_id", .uuid, .references(
                Schema.locationCategory, "id", onDelete: .setNull, onUpdate: .cascade
            ))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.location).delete()
    }
}
