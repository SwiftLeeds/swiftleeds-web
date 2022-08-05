import Foundation
import Fluent
import Vapor

class LocationMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.location)
             .id()
             .field("name", .string, .required)
             .field("url", .string, .required)
             .field("lat", .double, .required)
             .field("long", .double, .required)
             .field("category_id", .uuid, .references(
                Schema.locationCategory, "id", onDelete: .setNull, onUpdate: .cascade
             ))
             .create()
    }
    func revert(on database: Database) async throws {
        try await database.schema(Schema.location).delete()
    }

}
