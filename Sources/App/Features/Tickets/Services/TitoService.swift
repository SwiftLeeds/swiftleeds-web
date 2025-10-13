import Vapor

struct TitoService {
    let baseUrl = "https://api.tito.io/v3/swiftleeds"
    let event: String
    
    func ticket(payload: TicketLoginPayload, req: Request) async throws -> TitoTicketsResponse.Ticket? {
        // 1000 page size should guarantee all tickets are returned in one request (and is the maximum)
        // completed state search makes invalid, incomplete, or unpaid tickets are not returned
        let url = "\(baseUrl)/\(event)/tickets?search[states][]=complete&page[size]=1000&expand=release"
        
        let response = try await req.client.get(URI(string: url), headers: getHeaders())
        let ticketResponse = try response.content.decode(TitoTicketsResponse.self)
        
        if ticketResponse.meta.next_page != nil {
            req.logger.warning("There is an extra page of ticket results, login will not see new tickets...")
        }
        
        return ticketResponse.tickets.first(where: {
            // case insensitive comparisons
            $0.reference.lowercased() == payload.ticket.lowercased() &&
                $0.email?.lowercased() == payload.email.lowercased() &&
                // ensure unassigned tickets do not get captured here
                $0.email != nil
        })
    }
    
    func ticket(stub: String, req: Request) async throws -> TitoTicket? {
        let stub = stub.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
        
        if let cache = try? await req.cache.get("tito-\(stub)", as: TitoTicket.self) {
            // if a given ticket stub has been validated within the last hour then we can cache this in-memory
            return cache
        }
        
        let url = "\(baseUrl)/\(event)/tickets/\(stub)?expand=release,responses"
        
        let response = try await req.client.get(URI(string: url), headers: getHeaders())
        
        switch response.status.code {
        case 200: // ok
            let ticket = try response.content.decode(TitoResponse.self).ticket
            try await req.cache.set("tito-\(stub)", to: ticket, expiresIn: .hours(1))
            return ticket
            
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
            "Accept": "application/json",
        ]
    }
}

struct TitoTicketsResponse: Decodable {
    struct Ticket: Decodable {
        let slug: String
        let reference: String
        let email: String?
        let release: Release
    }
    
    struct Release: Decodable {
        let title: String
    }
    
    struct Meta: Decodable {
        let next_page: String?
        let total_pages: Int
        let per_page: Int
    }
    
    let tickets: [Ticket]
    let meta: Meta
}
