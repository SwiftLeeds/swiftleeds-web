import Vapor

struct SponsorScanResponse: Content {
    let name: String
    let firstName: String
    let lastName: String
    let company: String?
    let email: String
    let responses: [String: String]

    init(ticket: TitoTicket) {
        name = ticket.fullName
        firstName = ticket.first_name
        lastName = ticket.last_name
        company = ticket.company_name
        email = ticket.email
        responses = ticket.responses
    }
}

struct SponsorScanRequest: Content {
    let stub: String
}
