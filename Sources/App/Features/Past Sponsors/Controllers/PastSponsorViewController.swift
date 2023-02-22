import Fluent
import Vapor

struct PastSponsorViewController: RouteCollection {
    private struct PastSponsorContext: Content {
        let sponsor: PastSponsor?
        let events: [Event]
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onCreate)
        routes.get(":id", use: onEdit)
        routes.get("delete", ":id", use: onDelete)
    }
    
    private func onDelete(request: Request) async throws -> Response {
        guard let sponsor = try await PastSponsor.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }
        
        let events = try await Event.query(on: request.db).all()
        
        try await sponsor.delete(on: request.db)
        
        return request.redirect(to: "/admin?page=past-sponsors")
    }
        
    private func onCreate(request: Request) async throws -> View {
        let events = try await Event.query(on: request.db).all()
        let context = PastSponsorContext(sponsor: nil, events: events)
        
        return try await request.view.render("Authentication/past_sponsor_form", context)
    }
    
    private func onEdit(request: Request) async throws -> View {
        guard let sponsor = try await PastSponsor.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }
        
        let events = try await Event.query(on: request.db).all()
        let context = PastSponsorContext(sponsor: sponsor, events: events)
        
        return try await request.view.render("Authentication/past_sponsor_form", context)
    }
}
