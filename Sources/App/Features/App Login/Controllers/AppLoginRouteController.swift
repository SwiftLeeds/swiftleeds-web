import Fluent
import Vapor

struct AppLoginRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("ticket", use: login)
    }
    
    @Sendable private func login(request: Request) async throws -> String {
        let payload = try request.content.decode(AppLoginRequest.self, as: .json)
        
        var eventQuery = Event.query(on: request.db)
            .filter(\.$conference == request.application.conference.rawValue)
        
        if let eventId = payload.event {
            eventQuery = eventQuery.filter(\.$id == eventId)
        } else {
            eventQuery = eventQuery.filter(\.$isCurrent == true)
        }
        
        guard let event = try await eventQuery.first() else {
            throw Abort(.notFound, reason: "failed to identify event")
        }
        
        guard let titoEvent = event.titoEvent else {
            throw Abort(.internalServerError, reason: "login has not been setup for this event")
        }
        
        let lookup = TicketLoginPayload(email: payload.email, ticket: payload.ticket)
        guard let ticket = try await TitoService(event: titoEvent).ticket(payload: lookup, req: request) else {
            throw Abort(.forbidden)
        }
        
        guard let email = ticket.email else {
            // An email is `nil` when the ticket has not been assigned
            // This an impossible flow though as to get past the ticket lookup you must have matched the input email
            //   therefore ticket.email will always equal payload.email (± formatting)
            throw Abort(.internalServerError, reason: "requested unassigned ticket")
        }
        
        return try await request.jwt.sign(AppTicketJWTPayload(
            sub: .init(value: email),
            iat: .init(value: .now),
            slug: ticket.slug,
            reference: ticket.reference,
            event: event.requireID().uuidString,
            ticketType: ticket.release.title
        ))
    }
}
