import Vapor

struct SocialAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable func onGet(request: Request) async throws -> Response {
        let socialData = SocialService.getSocialData()
        
        let response = GenericResponse(
            data: socialData
        )
        
        return try await response.encodeResponse(for: request)
    }
}
