import Vapor
import Fluent

struct SponsorViewController: RouteCollection {
    
    private let sponsorLevels: [Sponsor.SponsorLevel] = [.silver, .gold, .platinum]

    private struct SponsorContext: Content {
        let sponsor: Sponsor?
        let sponsorLevels: [Sponsor.SponsorLevel]
        let events: [Event]
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onCreate)
        routes.get(":id", use: onEdit)
    }
        
    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        
        let events = try await Event.query(on: request.db).all()
        let context = SponsorContext(sponsor: nil, sponsorLevels: sponsorLevels, events: events)
        
        return try await request.view.render("Authentication/sponsor_form", context)
    }
    
    private func onEdit(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }

        guard let sponsor = try await Sponsor.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }
        
        let events = try await Event.query(on: request.db).all()
        let context = SponsorContext(sponsor: sponsor, sponsorLevels: sponsorLevels, events: events)
        
        return try await request.view.render("Authentication/sponsor_form", context)
    }
}
