import Vapor

struct AboutAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable func onGet(request: Request) async throws -> Response {
        let aboutData = AboutService.getAboutData()
        
        let response = GenericResponse(
            data: aboutData
        )
        
        return try await response.encodeResponse(for: request)
    }
}
