import Fluent

final class LastUpdatedMigrationV2: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let lastUpdated = LastUpdated(id: nil, sponsors: .distantPast, presentations: .distantPast, activities: .distantPast, speakers: .distantPast, slots: .distantPast, events: .distantPast)
        try await lastUpdated.save(on: database)
    }

    func revert(on database: any Database) async throws {
        try await LastUpdated.query(on: database).delete()
    }
}
