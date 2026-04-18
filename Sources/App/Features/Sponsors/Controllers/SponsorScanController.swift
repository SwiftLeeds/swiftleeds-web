import Vapor

struct SponsorScanController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let protected = routes.grouped(AppBearerMiddleware(), SponsorScanMiddleware())
        protected.post("scan", use: onScan)
    }

    /// Scan an attendee's QR code and return their details.
    /// - Parameter request: The incoming request containing the ticket stub
    /// - Returns: Attendee details (name, company, email, custom questions)
    @Sendable private func onScan(request: Request) async throws -> SponsorScanResponse {
        let payload = try request.content.decode(SponsorScanRequest.self)

        guard let currentEvent = request.storage.get(CurrentEventKey.self),
              let titoEvent = currentEvent.titoEvent
        else {
            throw Abort(.internalServerError, reason: "Unable to identify event")
        }

        guard let attendeeTicket = try await TitoService(event: titoEvent).ticket(stub: payload.stub, req: request) else {
            throw Abort(.notFound, reason: "Ticket not found")
        }

        return SponsorScanResponse(ticket: attendeeTicket)
    }
}
