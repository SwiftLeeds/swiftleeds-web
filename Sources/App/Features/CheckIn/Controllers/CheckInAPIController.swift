import Vapor

struct CheckInAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(":secret", use: onGet)
    }
    
    @Sendable func onGet(request: Request) async throws -> CheckIn {
        // Verified that :secret (in the route /api/v1/checkin/:secret) is equal to `CHECKIN_SECRET`
        guard
            let secret = request.parameters.get("secret"),
            let checkinSecret = Environment.get("CHECKIN_SECRET"),
            secret == checkinSecret
        else {
            throw Abort(.notFound)
        }
        
        // If it is, then return Event.checkinKey or `CHECKIN_TAG`
        let event = try await Event.getCurrent(req: request)
        return CheckIn(tag: event.checkinKey ?? Environment.get("CHECKIN_TAG") ?? "")
    }
    
    struct CheckIn: Content {
        let tag: String
    }
}
