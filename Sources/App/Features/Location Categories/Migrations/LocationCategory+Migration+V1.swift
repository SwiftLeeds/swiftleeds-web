import Fluent
import Foundation
import Vapor

final class LocationCategoryMigrationV1: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Schema.locationCategory)
            .id()
            .field("name", .string, .required)
            .field("symbol_name", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Schema.locationCategory).delete()
    }
}
