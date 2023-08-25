import Fluent
import Vapor

struct PresentationRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }
        
    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, presentation: nil)
    }
    
    private func onShowEdit(request: Request) async throws -> View {
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await showForm(request: request, presentation: presentation)
    }

    private func showForm(request: Request, presentation: Presentation?) async throws -> View {
        let speakers = try await Speaker.query(on: request.db).sort(\.$name).all()
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = PresentationContext(presentation: presentation, speakers: speakers, events: events, hasSecondSpeaker: presentation?.$secondSpeaker.id != nil)

        return try await request.view.render("Admin/Form/presentation_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }

        try await presentation.delete(on: request.db)

        return request.redirect(to: "/admin?page=presentations")
    }

    private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, presentation: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=presentations")
        }

        return try await update(request: request, presentation: presentation)
    }

    private func update(request: Request, presentation: Presentation?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard
            let speaker = try await Speaker.find(UUID(uuidString: input.speakerID), on: request.db),
            let event = try await Event.find(.init(uuidString: input.eventID), on: request.db)
        else {
            return request.redirect(to: "/admin?page=presentations")
        }

        if let presentation = presentation {
            presentation.title = input.title
            presentation.synopsis = input.synopsis
            presentation.isTBA = false
            presentation.slidoURL = input.slidoURL
            presentation.videoURL = input.videoURL

            presentation.$speaker.id = try speaker.requireID()
            presentation.$event.id = try event.requireID()

            if let secondSpeakerID = input.secondSpeakerID {
                guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                    return request.redirect(to: "/admin?page=presentations")
                }
                presentation.$secondSpeaker.id = try secondSpeaker.requireID()
            } else {
                let emptySpeakerID: Speaker.IDValue? = nil
                presentation.$secondSpeaker.id = emptySpeakerID
            }

            try await presentation.update(on: request.db)
        } else {
            let presentation = Presentation(
                id: .generateRandom(),
                title: input.title,
                synopsis: input.synopsis,
                isTBA: false,
                slidoURL: input.slidoURL,
                videoURL: input.videoURL
            )

            presentation.$speaker.id = try speaker.requireID()
            presentation.$event.id = try event.requireID()

            if let secondSpeakerID = input.secondSpeakerID {
                guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                    return request.redirect(to: "/admin?page=presentations")
                }
                presentation.$secondSpeaker.id = try secondSpeaker.requireID()
            } else {
                let emptySpeakerID: Speaker.IDValue? = nil
                presentation.$secondSpeaker.id = emptySpeakerID
            }

            try await presentation.create(on: request.db)
        }

        return request.redirect(to: "/admin?page=presentations")
    }

    // MARK: - PresentationContext
    private struct PresentationContext: Content {
        let presentation: Presentation?
        let speakers: [Speaker]
        let events: [Event]
        let hasSecondSpeaker: Bool
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let speakerID: String
        let secondSpeakerID: String?
        let eventID: String
        let title: String
        let synopsis: String
        let slidoURL: String?
        let videoURL: String?
    }
}
