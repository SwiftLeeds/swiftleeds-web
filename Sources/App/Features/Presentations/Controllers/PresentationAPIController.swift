import Vapor
import Fluent

struct PresentationAPIController: RouteCollection {
    
    private struct FormInput: Content {
        let speakerID: String
        let eventID: String
        let title: String
        let synopsis: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("", use: onPost)
        routes.post(":id", use: onEdit)
    }

    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        
        guard let speaker = try await Speaker.find(UUID(uuidString: input.speakerID), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        let presentation = Presentation(
            id: .generateRandom(),
            title: input.title,
            synopsis: input.synopsis,
            image: nil,
            isTBA: false
        )
        
        presentation.$speaker.id = try speaker.requireID()
        presentation.$event.id = try event.requireID()
        
        try await presentation.create(on: request.db)
        
        return request.redirect(to: "/admin")
    }
    
    private func onEdit(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        
        guard let speaker = try await Speaker.find(.init(uuidString: input.speakerID), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        presentation.title = input.title
        presentation.synopsis = input.synopsis
        presentation.image = nil
        presentation.isTBA = false
        
        presentation.$speaker.id = try speaker.requireID()
        presentation.$event.id = try event.requireID()
        
        try await presentation.update(on: request.db)
        
        return request.redirect(to: "/admin")
    }
}
