import Fluent
import Vapor

struct PresentationRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Modal
        routes.get(use: onRead)
        routes.get(":id", use: onRead)
        
        // Form
        routes.post("create", use: onCreate)
        routes.post(":id", "delete", use: onDelete)
        routes.post(":id", "update", use: onUpdate)
    }
    
    @Sendable private func onRead(request: Request) async throws -> View {
        let presentation = try await request.parameters.get("id").map { Presentation.find($0, on: request.db) }?.get()
        let speakers = try await Speaker.query(on: request.db).sort(\.$name).all()
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = PresentationContext(presentation: presentation, speakers: speakers, events: events, hasSecondSpeaker: presentation?.$secondSpeaker.id != nil)

        return try await request.view.render("Admin/Form/presentation_form", context)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        try await presentation.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, presentation: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let presentation = try await Presentation.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find presentation")
        }

        return try await update(request: request, presentation: presentation)
    }

    private func update(request: Request, presentation: Presentation?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard
            let speaker = try await Speaker.find(UUID(uuidString: input.speakerID), on: request.db),
            let event = try await Event.find(.init(uuidString: input.eventID), on: request.db)
        else {
            throw Abort(.badRequest, reason: "Could not find speaker or event")
        }

        if let presentation = presentation {
            presentation.title = input.title
            presentation.synopsis = input.synopsis
            presentation.isTBA = !(input.isAnnounced == "on")
            presentation.slidoURL = input.slidoURL
            presentation.videoURL = input.videoURL
            presentation.duration = input.duration

            presentation.$speaker.id = try speaker.requireID()
            presentation.$event.id = try event.requireID()

            if let secondSpeakerID = input.secondSpeakerID {
                guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                    throw Abort(.badRequest, reason: "Could not find second speaker")
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

            presentation.duration = input.duration
            presentation.$speaker.id = try speaker.requireID()
            presentation.$event.id = try event.requireID()

            if let secondSpeakerID = input.secondSpeakerID {
                guard let secondSpeaker = try await Speaker.find(UUID(uuidString: secondSpeakerID), on: request.db) else {
                    throw Abort(.badRequest, reason: "Could not find second speaker")
                }
                presentation.$secondSpeaker.id = try secondSpeaker.requireID()
            } else {
                let emptySpeakerID: Speaker.IDValue? = nil
                presentation.$secondSpeaker.id = emptySpeakerID
            }

            try await presentation.create(on: request.db)
        }

        return Response(status: .ok, body: .init(string: "OK"))
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
        let duration: Double
        let slidoURL: String?
        let videoURL: String?
        let isAnnounced: String?
    }
}
