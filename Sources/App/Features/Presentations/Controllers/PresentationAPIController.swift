import Vapor
import Fluent

struct PresentationAPIController: RouteCollection {
    
    private struct FormInput: Content {
        let speakerID: String
        let secondSpeakerID: String?
        let eventID: String
        let title: String
        let synopsis: String
        let slidoURL: String?
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post(use: onPost)
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
            isTBA: false,
            slidoURL: input.slidoURL
        )
        
        presentation.$speaker.id = try speaker.requireID()
        presentation.$event.id = try event.requireID()

        if let secondSpeakerID = input.secondSpeakerID {
            guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                return request.redirect(to: "/admin")
            }
            presentation.$secondSpeaker.id = try secondSpeaker.requireID()
        } else {
            presentation.$secondSpeaker.id = nil
        }
        
        try await presentation.create(on: request.db)
        
        return request.redirect(to: "/admin?page=presentations")
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
        presentation.isTBA = false
        presentation.slidoURL = input.slidoURL
        
        presentation.$speaker.id = try speaker.requireID()
        presentation.$event.id = try event.requireID()

        if let secondSpeakerID = input.secondSpeakerID {
            guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                return request.redirect(to: "/admin")
            }
            presentation.$secondSpeaker.id = try secondSpeaker.requireID()
        } else {
            presentation.$secondSpeaker.id = nil
        }
        
        try await presentation.update(on: request.db)
        
        return request.redirect(to: "/admin?page=presentations")
    }
}
