import Fluent
import Vapor

struct ActivityRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        // Modal
        routes.get(use: onRead)
        routes.get(":id", use: onRead)
        
        // Form
        routes.post("create", use: onCreate)
        routes.post(":id", "delete", use: onDelete)
        routes.post(":id", "update", use: onUpdate)
    }

    @Sendable private func onRead(request: Request) async throws -> View {
        let activity = try await request.parameters.get("id").map { Activity.find($0, on: request.db) }?.get()
        try await activity?.$event.load(on: request.db)
        
        let context = try await buildContext(from: request.db, activity: activity)
        return try await request.view.render("Admin/Form/activity_form", context)
    }

    private func buildContext(from db: any Database, activity: Activity?) async throws -> ActivityContext {
        let events = try await Event.query(on: db).sort(\.$date).all()
        return ActivityContext(activity: activity, events: events)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        try await activity.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, activity: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find activity")
        }

        return try await update(request: request, activity: activity)
    }

    private func update(request: Request, activity: Activity?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)

        let event: Event? = try await {
            // If explicitly defined as no event, then return nil.
            if input.eventID == "none" {
                return nil
            }
            
            // Otherwise, if an event was defined then throw an error if you can't find it.
            guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
                throw Abort(.badRequest, reason: "Could not find event")
            }
        
            return event
        }()

        if let activity = activity {
            var fileName = activity.image

            if !image.activityImage.filename.isEmpty {
                let tempFileName = "\(UUID.generateRandom().uuidString)-\(image.activityImage.filename)"

                try await ImageService.uploadFile(
                    data: Data(image.activityImage.data.readableBytesView),
                    filename: tempFileName
                )
                fileName = tempFileName
            }

            activity.title = input.title
            activity.subtitle = input.subtitle
            activity.description = input.description
            activity.metadataURL = input.metadataURL
            activity.image = fileName
            activity.duration = input.duration

            activity.$event.id = try event?.requireID()

            try await activity.update(on: request.db)
        } else {
            var fileName: String?

            if !image.activityImage.filename.isEmpty {
                fileName = "\(UUID.generateRandom().uuidString)-\(image.activityImage.filename)"

                try await ImageService.uploadFile(
                    data: Data(image.activityImage.data.readableBytesView),
                    filename: fileName!
                )
            }

            let activity = Activity(
                id: .generateRandom(),
                title: input.title,
                subtitle: input.subtitle,
                description: input.description,
                metadataURL: input.metadataURL,
                image: fileName
            )

            activity.duration = input.duration
            activity.$event.id = try event?.requireID()

            try await activity.create(on: request.db)
        }

        return Response(status: .ok, body: .init(string: "OK"))
    }

    // MARK: - ActivityContext
    private struct ActivityContext: Content {
        let activity: Activity?
        let events: [Event]
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let eventID: String
        let title: String
        let duration: Double
        let subtitle: String?
        let description: String?
        let metadataURL: String?
    }

    // MARK: - ImageUpload
    struct ImageUpload: Content {
        var activityImage: File
    }
}
