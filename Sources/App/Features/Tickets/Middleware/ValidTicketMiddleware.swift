import Vapor
import Fluent

struct ValidTicketMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let currentEvent = try await Event.query(on: request.db).filter(\.$isCurrent == true).first() else {
            throw Abort(.badRequest, reason: "unable to identify current event")
        }
        
        guard let titoEvent = currentEvent.titoEvent else {
            throw Abort(.badRequest, reason: "unable to identify tito project")
        }
        
        await request.storage.setWithAsyncShutdown(CurrentEventKey.self, to: currentEvent)
        
        #if DEBUG
        // append ?skipTicket=true to route in debug builds in order to bypass tito
        if request.application.environment.isRelease == false {
            let value: String? = try? request.query.get(at: "skipTicket")
            
            if value == "true" {
                await request.storage.setWithAsyncShutdown(TicketStorage.self, to: .init(
                    first_name: "James",
                    last_name: "Sherlock",
                    slug: "ti_test_p05Ch95xJS5AStInfa8whFA",
                    company_name: nil,
                    avatar_url: nil,
                    responses: [:],
                    release: .init(metadata: .init(canBookDropInSession: true)),
                    email: "james@gmail.com",
                    reference: "ABCD-1"
                ))
                
                return try await next.respond(to: request)
            }
        }
        #endif
        
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
