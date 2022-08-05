import Foundation
import Fluent
import Vapor

class LocationCategoryMigrationV1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Schema.locationCategory)
             .id()
             .field("name", .string, .required)
             .field("symbol_name", .string, .required)
             .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Schema.locationCategory).delete()
    }

}
