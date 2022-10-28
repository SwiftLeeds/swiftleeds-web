import Fluent
import Vapor

struct PresentationViewController: RouteCollection {
    private struct PresentationContext: Content {
        let presentation: Presentation?
        let speakers: [Speaker]
        let events: [Event]
        let hasSecondSpeaker: Bool
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onCreate)
        routes.get(":id", use: onEdit)
    }
        
    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        
        let speakers = try await Speaker.query(on: request.db).all()
        let events = try await Event.query(on: request.db).all()
        let context = PresentationContext(presentation: nil, speakers: speakers, events: events, hasSecondSpeaker: false)
        
        return try await request.view.render("Authentication/presentation_form", context)
    }
    
    private func onEdit(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }

        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }

        let speakers = try await Speaker.query(on: request.db).all()
        let events = try await Event.query(on: request.db).all()
        let context = PresentationContext(presentation: presentation, speakers: speakers, events: events, hasSecondSpeaker: presentation.$secondSpeaker.id != nil)
        
        return try await request.view.render("Authentication/presentation_form", context)
    }
}
