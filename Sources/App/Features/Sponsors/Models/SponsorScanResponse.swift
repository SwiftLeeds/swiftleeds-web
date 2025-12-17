import Vapor

struct SponsorScanResponse: Content {
    let name: String
    let company: String?
    let email: String
    let responses: [String: String]

    init(ticket: TitoTicket) {
        self.name = ticket.fullName
        self.company = ticket.company_name
        self.email = ticket.email
        self.responses = ticket.responses
    }
}

struct SponsorScanRequest: Content {
    let stub: String
}
