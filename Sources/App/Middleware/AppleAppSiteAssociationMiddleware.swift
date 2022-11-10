import Vapor

struct AppleAppSiteAssociationMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard request.url.string == "/.well-known/apple-app-site-association" else {
            return try await next.respond(to: request)
        }

        let response = try await next.respond(to: request)
        response.headers.add(name: "content-type", value: "application/json")
        return response
    }
}
