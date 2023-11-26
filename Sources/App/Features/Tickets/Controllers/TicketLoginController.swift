import Vapor

struct TicketLoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("ticketLogin") { req async throws -> View in
            req.session.data["ticketRedirectUrl"] = req.query["returnUrl"]
            return try await req.leaf.render(
                "Ticket/ticketLogin",
                TicketLoginContext(prompt: req.query["prompt"])
            )
        }
        
        routes.post("ticketLogin", "validate") { req async throws -> Response in
            // Get user input
            let input = try req.content.decode(TicketLoginPayload.self)
            
            // Validate ticket
            let ticketOpt = try await TitoService(event: currentEvent)
                .ticket(payload: input, req: req)
            
            // Handle errors
            guard let ticket = ticketOpt else {
                let message = "We were unable to locate your ticket. Contact support if the problem persists."
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/ticketLogin?prompt=\(message ?? "")")
            }
            
            // Update session
            req.session.data["tito-\(currentEvent)"] = ticket.slug
            
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
