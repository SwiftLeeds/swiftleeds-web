import Vapor

struct TicketLoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("ticketLogin") { req in
            // TODO: (James) if error query param, show error alert on page
            
            req.session.data["ticketRedirectUrl"] = req.query["returnUrl"]
            return try await req.leaf.render("Ticket/ticketLogin")
        }
        
        routes.post("ticketLogin", "validate") { req async throws in
            // Get user input
            let input = try req.content.decode(TicketLoginPayload.self)
            
            // Validate ticket
            let ticketOpt = try await TitoService(event: currentEvent)
                .ticket(payload: input, req: req)
            
            // Handle errors
            guard let ticket = ticketOpt else {
                req.logger.info("failed to match ticket")
                return req.redirect(to: "/ticketLogin?error=true")
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
