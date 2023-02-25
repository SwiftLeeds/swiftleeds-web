import Vapor

struct ValidTicketMiddleware: AsyncMiddleware {
    let event: String
    
    init() {
        event = currentEvent
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let returnUrl = request.url.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .map { "?returnUrl=" + $0 } ?? ""
        
        let sessionKey = "tito-\(event)"
        
        if let ticket = request.session.data[sessionKey] {
            // validate ticket stub against tito
            guard let ticket = try await TitoService(event: event).ticket(stub: ticket, req: request) else {
                // invalid, clear session and go back to login page
                request.session.data[sessionKey] = nil
                return request.redirect(to: "/ticketLogin" + returnUrl)
            }
            
            // store ticket for use in routes
            request.storage.set(TicketStorage.self, to: ticket)
            
            // continue with request
            return try await next.respond(to: request)
        } else {
            // no ticket in session, go to login
            return request.redirect(to: "/ticketLogin" + returnUrl)
        }
    }
}

let currentEvent = "swiftleeds-23"

struct TicketStorage: StorageKey {
    typealias Value = TitoTicket
}
