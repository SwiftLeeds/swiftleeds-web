import Vapor

struct CheckInAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(":secret", use: onGet)
    }
    
    @Sendable func onGet(request: Request) throws -> CheckIn {
        // Verified that :secret (in the route /api/v1/checkin/:secret) is equal to `CHECKIN_SECRET`
        // If it is, then return `CHECKIN_TAG`
        guard
            let secret = request.parameters.get("secret"),
            let checkinSecret = Environment.get("CHECKIN_SECRET"),
            secret == checkinSecret,
            let tag = Environment.get("CHECKIN_TAG")
        else {
            throw Abort(.notFound)
        }

        return CheckIn(tag: tag)
    }
    
    struct CheckIn: Content {
        let tag: String
    }
}
