import Vapor
import Fluent

struct ValidTicketMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let currentEvent = try await Event.query(on: request.db).filter(\.$isCurrent == true).first() else {
            throw Abort(.badRequest, reason: "unable to identify current event")
        }
        
        try await currentEvent.$days.load(on: request.db)
        
        guard let titoEvent = currentEvent.titoEvent else {
            throw Abort(.badRequest, reason: "unable to identify tito project")
        }
        
        await request.storage.setWithAsyncShutdown(CurrentEventKey.self, to: currentEvent)
        
        let returnUrl = request.url.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .map { "?returnUrl=" + $0 } ?? ""
        
        let sessionKey = "tito-\(titoEvent)"
        
        if let ticket = request.session.data[sessionKey] {
            // validate ticket stub against tito
            guard let ticket = try await TitoService(event: titoEvent).ticket(stub: ticket, req: request) else {
                // invalid, clear session and go back to login page
                request.session.data[sessionKey] = nil
                return request.redirect(to: "/ticketLogin" + returnUrl)
            }
            
            // store ticket for use in routes
            await request.storage.setWithAsyncShutdown(TicketStorage.self, to: ticket)
            
            // continue with request
            return try await next.respond(to: request)
        } else {
            // no ticket in session, go to login
            return request.redirect(to: "/ticketLogin" + returnUrl)
        }
    }
}

struct TicketStorage: StorageKey {
    typealias Value = TitoTicket
}

struct CurrentEventKey: StorageKey {
    typealias Value = Event
}
