import Foundation
import Fluent

struct JobMiddleware: AsyncModelMiddleware {
    func create(model: Job, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.create(model, on: db)
        try await updateTimestamp(on: db, title: model.title)
    }

    func update(model: Job, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.update(model, on: db)
        try await updateTimestamp(on: db, title: model.title)
    }

    func delete(model: Job, force: Bool, on db: any Database, next: any AnyAsyncModelResponder) async throws {
        try await next.delete(model, force: force, on: db)
        try await updateTimestamp(on: db, title: model.title)
    }

    private func updateTimestamp(on db: any Database, title: String) async throws {
        guard let lastUpdated = try await LastUpdated
            .query(on: db)
            .first()
        else { throw ModelMiddlewareError.couldNotUpdateTimestamp }

        let updatedDate = Date()
        print("Job \(title) was updated - \(updatedDate)")

        lastUpdated.sponsors = updatedDate
        try await lastUpdated.save(on: db)
    }

    private enum ModelMiddlewareError: Error {
        case couldNotUpdateTimestamp
    }
}
