import Fluent
import Vapor

struct AppBearerMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let token = request.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized)
        }
        
        let payload = try await request.jwt.verify(token, as: AppTicketJWTPayload.self)
        
        guard let currentEvent = try await Event.query(on: request.db).filter(\.$id == payload.event).first() else {
            throw Abort(.internalServerError)
        }
        
        try await currentEvent.$days.load(on: request.db)
        
        guard let titoEvent = currentEvent.titoEvent else {
            throw Abort(.badRequest, reason: "unable to identify tito project")
        }
        
        await request.storage.setWithAsyncShutdown(CurrentEventKey.self, to: currentEvent)
        
        guard let ticket = try await TitoService(event: titoEvent).ticket(stub: payload.slug, req: request) else {
            throw Abort(.unauthorized)
        }
        
        await request.storage.setWithAsyncShutdown(TicketStorage.self, to: ticket)
        return try await next.respond(to: request)
    }
}
