import Vapor

struct TitoService {
    let baseUrl = "https://api.tito.io/v3/swiftleeds"
    let event: String
    
    func ticket(payload: TicketLoginPayload, req: Request) async throws -> TitoTicketsResponse.Ticket? {
        let url = "\(baseUrl)/\(event)/tickets?search[states][]=complete"
        
        let response = try await req.client.get(URI(string: url), headers: getHeaders())
        
        // TODO: (James) if ticket is not on page one, go to page two, and three... etc
        let tickets = try response.content.decode(TitoTicketsResponse.self).tickets
        
        let ticketOpt = tickets.first(where: {
            // case insensitive comparisons
            $0.reference.lowercased() == payload.ticket.lowercased() &&
            $0.email.lowercased() == payload.email.lowercased()
        })
        
        guard let ticket = ticketOpt else {
            return nil
        }
        
        return ticket
    }
    
    func ticket(stub: String, req: Request) async throws -> TitoTicket? {
        let stub = stub.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
        let url = "\(baseUrl)/\(event)/tickets/\(stub)"
        
        let response = try await req.client.get(URI(string: url), headers: getHeaders())
        
        switch response.status.code {
        case 200: // ok
            return try response.content.decode(TitoResponse.self).ticket
            
        case 404: // not found
            return nil
            
        default:
            throw Abort(response.status, reason: "Failed to locate provided ticket on remote server")
        }
    }
    
    private func getToken() throws -> String {
        guard let auth = Environment.get("TITO_TOKEN") else {
            throw Abort(.unauthorized, reason: "Server was not setup to authorise requests with ticket server")
        }
        
        return auth
    }
    
    private func getHeaders() throws -> HTTPHeaders {
        let auth = try getToken()
        
        return [
            "Authorization": "Token token=\(auth)",
            "Accept": "application/json"
        ]
    }
    
}

struct TitoTicketsResponse: Decodable {
    struct Ticket: Decodable {
        let slug: String
        let reference: String
        let email: String
    }
    
    struct Meta: Decodable {
        let next_page: String?
        let total_pages: Int
    }
    
    let tickets: [Ticket]
    let meta: Meta
}
