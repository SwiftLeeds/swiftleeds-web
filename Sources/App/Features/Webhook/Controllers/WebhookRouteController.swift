import Vapor

struct WebhookRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("webhook", use: onReceive)
    }
    
    @Sendable private func onReceive(request: Request) async throws -> String {
        guard let webhookName = request.headers["x-webhook-name"].first else { return "No webhook name found" }
        guard let titoWebhook = TitoWebhook(rawValue: webhookName) else { return "Webhook name not recognised" }
        
        switch titoWebhook {
        case .checkinCreated, .checkinDeleted:
            break
        case .ticketCreated, .ticketCompleted, .ticketReassigned, .ticketUpdated, .ticketUnsnoozed, .ticketUnvoided, .ticketVoided:
            break
        case .registrationUpdated, .registrationFinished, .registrationCompleted, .registrationCancelled, .registrationMarkedAsPaid, .registrationMarkedAsUnpaid:
            try await handleRegistrationUpdate(req: request, webhook: titoWebhook)
        }
        
        return ""
    }
    
    @Sendable func handleRegistrationUpdate(req: Request, webhook: TitoWebhook) async throws {
        guard let ticketChannel = Environment.get("TICKET_CHANNEL") else { throw Abort(.notFound) }
        
        let registration = try req.content.decode(TitoRegistration.self)
        
        let message = generateRegistrationMessage(for: registration)
        let details = generateRegistrationDetails(for: registration)
        
        let slackMessage = SlackMessage(channel: ticketChannel, icon_emoji: ":admission_tickets:", username: registration.event.title, blocks: [
            .init(type: .section, text: .init(type: .markdown, text: message)),
            .init(type: .section, text: .init(type: .markdown, text: details)),
            .init(type: .divider)
        ])
        
        try await slackMessage.send(req: req)
    }
    
    @Sendable private func generateRegistrationMessage(for registration: TitoRegistration) -> String {
        var message = "*\(registration.fullName)* "
        
        if let companyName = registration.company_name {
            message += "from \(companyName) "
        }
        
        message += "registered \(registration.tickets.count) ticket\(registration.tickets.count > 1 ? "s" : "") "
        message += "(<https://dashboard.tito.io/\(registration.event.account_slug)/\(registration.event.slug)/registrations/\(registration.slug)|Tito Dashboard>)"
        
        if registration.test_mode {
            message = "[TEST] \(message)"
        }
        
        return message
    }
    
    @Sendable private func generateRegistrationDetails(for registration: TitoRegistration) -> String {
        var details = ""
        
        registration.tickets.forEach { ticket in
            details += "_• \(ticket.release_title) "
            
            if let fullName = ticket.fullName {
                details += "[\(fullName)]"
            } else {
                details += "[Unassigned]"
            }
            
            if let upgrades = ticket.upgrades {
                details.append(" + \(upgrades.map { $0.title }.joined(separator: ","))")
            }
            
            details += "_\n"
        }
        
        return details
    }
    
    // MARK: - TitoWebhook
    enum TitoWebhook: String {
        case checkinCreated = "checkin.created"
        case checkinDeleted = "checkin.deleted"
        case ticketCreated = "ticket.created"
        case ticketCompleted = "ticket.completed"
        case ticketReassigned = "ticket.reassigned"
        case ticketUpdated = "ticket.updated"
        case ticketUnsnoozed = "ticket.unsnoozed"
        case ticketUnvoided = "ticket.unvoided"
        case ticketVoided = "ticket.voided"
        case registrationUpdated = "registration.updated"
        case registrationFinished = "registration.finished"
        case registrationCompleted = "registration.completed"
        case registrationCancelled = "registration.cancelled"
        case registrationMarkedAsPaid = "registration.marked_as_paid"
        case registrationMarkedAsUnpaid = "registration.marked_as_unpaid"
    }
}
