import Vapor

/// Middleware that validates the authenticated user has a sponsor ticket type.
/// This middleware must be used after `AppBearerMiddleware` which validates the JWT
/// and stores the ticket in request storage.
struct SponsorScanMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "No authorization token provided")
        }

        let payload = try await request.jwt.verify(token, as: AppTicketJWTPayload.self)

        // Check if the ticket type contains "sponsor"
        guard payload.ticketType.lowercased().contains("sponsor") else {
            throw Abort(.forbidden, reason: "Sponsor ticket required to access this endpoint")
        }

        return try await next.respond(to: request)
    }
}
