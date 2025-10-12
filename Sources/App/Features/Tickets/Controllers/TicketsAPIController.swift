import Vapor

struct TicketsAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(":event", use: onGet)
    }
    
    @Sendable private func onGet(request: Request) async throws -> Response {
        guard let event = request.parameters.get("event") else { // example: swiftleeds-23
            throw Abort(.badRequest, reason: "Event parameter was not provided to GET request")
        }
        
        guard let stubInput: String = try request.query.get(at: "stub") else { // example: ti_xxxxxxxxxxxxxxxxxxx
            throw Abort(.badRequest, reason: "Ticket identifier was not provided as 'stub' URL parameter")
        }
        
        guard let ticket = try await TitoService(event: event).ticket(stub: stubInput, req: request) else {
            throw Abort(.notFound, reason: "The ticket provided does not exist")
        }
        
        return try await TicketTransformer.transform(ticket).encodeResponse(for: request)
    }
}
