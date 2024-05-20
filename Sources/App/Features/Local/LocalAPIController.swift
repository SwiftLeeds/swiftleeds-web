import Fluent
import Vapor

struct LocalAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable private func onGet(request: Request) async throws -> Response {
        let categories = try await LocationCategory.query(on: request.db)
            .with(\.$locations)
            .all()
        let response = GenericResponse(
            data: categories.compactMap(LocationCategoryTransformer.transform(_:))
        )
        return try await response.encodeResponse(for: request)
    }
}
