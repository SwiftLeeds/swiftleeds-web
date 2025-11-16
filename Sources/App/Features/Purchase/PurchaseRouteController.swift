import Vapor

struct PurchaseRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let route = routes.grouped(User.sessionAuthenticator())
        route.get("purchase", use: get)
    }
    
    @Sendable func get(req: Request) async throws -> View {
        let event = try await Event.getCurrent(req: req)
        try await event.$days.load(on: req.db)
        return try await req.view.render("Purchase/index", HomeContext(event: EventContext(event: event)))
    }
}
