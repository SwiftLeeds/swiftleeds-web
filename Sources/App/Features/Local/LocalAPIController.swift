//
//  LocalAPIController.swift
//
//
//  Created by Alex Logan on 25/07/2022.
//

import Vapor
import Fluent

struct LocalAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onGet)
    }

    private func onGet(request: Request) async throws -> Response {
        let categories = try await LocationCategory.query(on: request.db)
            .with(\.$locations)
            .all()
        let response = GenericResponse(
            data: categories.compactMap(LocationCategoryTransformer.transform(_:))
        )
        return try await response.encodeResponse(for: request)
    }
}

private extension ScheduleAPIController {
    enum ScheduleAPIError: Error {
        case notFound
        case transformFailure
    }
}
