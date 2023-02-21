import Vapor

struct TicketsAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(":event", use: onGet)
    }
    
    private func onGet(request: Request) async throws -> Response {
        guard let auth = Environment.get("TITO_TOKEN") else {
            throw Abort(.unauthorized, reason: "Server was not setup to authorise requests with ticket server")
        }
        
        guard let event = request.parameters.get("event") else { // example: swiftleeds-23
            throw Abort(.badRequest, reason: "Event parameter was not provided to GET request")
        }
        
        guard let stubInput: String = try request.query.get(at: "stub") else { // example: ti_xxxxxxxxxxxxxxxxxxx
            throw Abort(.badRequest, reason: "Ticket identifier was not provided as 'stub' URL parameter")
        }
        
        let stub = stubInput.replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
        let url = "https://api.tito.io/v3/swiftleeds/\(event)/tickets/\(stub)"
        
        let response = try await request.client.get(URI(string: url), headers: [
            "Authorization": "Token token=\(auth)",
            "Accept": "application/json"
        ])
        
        switch response.status.code {
        case 200: // ok
            let ticket = try response.content.decode(TitoResponse.self).ticket
            return try await TicketTransformer.transform(ticket).encodeResponse(for: request)
            
        case 404: // not found
            throw Abort(.notFound, reason: "The ticket provided does not exist")
            
        default:
            throw Abort(response.status, reason: "Failed to locate provided ticket on remote server")
        }
    }
}
