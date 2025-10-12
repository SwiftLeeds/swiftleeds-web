import Foundation
import Fluent

struct SponsorMiddleware: AsyncModelMiddleware {
    func create(model: Sponsor, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.create(model, on: db)
        try await updateTimestamp(on: db, name: model.name)
    }

    func update(model: Sponsor, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.update(model, on: db)
        try await updateTimestamp(on: db, name: model.name)
    }

    func delete(model: Sponsor, force: Bool, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.delete(model, force: force, on: db)
        try await updateTimestamp(on: db, name: model.name)
    }

    private func updateTimestamp(on db: any Database, name: String) async throws {
        guard let lastUpdated = try await LastUpdated
            .query(on: db)
            .first()
        else { throw SponsorMiddlewareError.couldNotUpdateTimestamp }

        let updatedDate = Date()
        db.logger.info("Sponsor \(name) was updated - \(updatedDate)")

        lastUpdated.sponsors = updatedDate
        try await lastUpdated.save(on: db)
    }

    private enum SponsorMiddlewareError: Error {
        case couldNotUpdateTimestamp
    }
}
