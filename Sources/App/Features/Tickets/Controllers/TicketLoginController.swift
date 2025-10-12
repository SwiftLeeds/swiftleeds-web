import Vapor
import Fluent

struct TicketLoginController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("ticketLogin") { req async throws -> View in
            if let query: String = req.query["returnUrl"] {
                req.session.data["ticketRedirectUrl"] = query
            }
            
            return try await req.leaf.render(
                "Ticket/ticketLogin",
                TicketLoginContext(prompt: req.query["prompt"])
            )
        }
        
        routes.post("ticketLogin", "validate") { req async throws -> Response in
            guard let currentTitoEvent = try await Event.query(on: req.db).filter(\.$isCurrent == true).first()?.titoEvent else {
                throw Abort(.badRequest, reason: "unable to identify current event")
            }
            
            // Get user input
            let input = try req.content.decode(TicketLoginPayload.self)
            
            // Validate ticket
            let ticketOpt = try await TitoService(event: currentTitoEvent)
                .ticket(payload: input, req: req)
            
            // Handle errors
            guard let ticket = ticketOpt else {
                let message = "We were unable to locate your ticket. Contact support if the problem persists."
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/ticketLogin?prompt=\(message ?? "")")
            }
            
            if ticket.release.title.lowercased().contains("talkshow") {
                let message = "You cannot login with a talkshow ticket. Please use your main event ticket and try again."
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/ticketLogin?prompt=\(message ?? "")")
            }
            
            // Update session
            req.session.data["tito-\(currentTitoEvent)"] = ticket.slug
            
            // Redirect
            let redirectUrl = req.session.data["ticketRedirectUrl"] ?? "/"
            req.session.data["ticketRedirectUrl"] = nil
            
            return req.redirect(to: redirectUrl)
        }
    }
}

struct TicketLoginPayload: Decodable {
    let email: String
    let ticket: String
}

struct TicketLoginContext: Codable {
    let prompt: String?
}
