import Fluent
import Vapor

struct ActivityRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }

    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, activity: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await activity.$event.load(on: request.db)

        return try await showForm(request: request, activity: activity)
    }

    private func showForm(request: Request, activity: Activity?) async throws -> View {
        let context = try await buildContext(from: request.db, activity: activity)
        return try await request.view.render("Admin/Form/activity_form", context)
    }

    private func buildContext(from db: Database, activity: Activity?) async throws -> ActivityContext {
        let events = try await Event.query(on: db).sort(\.$date).all()
        return ActivityContext(activity: activity, events: events)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await activity.delete(on: request.db)

        return request.redirect(to: "/admin?page=activities")
    }

    private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, activity: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        return try await update(request: request, activity: activity)
    }

    private func update(request: Request, activity: Activity?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        if let activity = activity {
            var fileName = activity.image

            if !image.activityImage.filename.isEmpty {
                let tempFileName = "\(UUID.generateRandom().uuidString)-\(image.activityImage.filename)"

                do {
                    try await ImageService.uploadFile(
                        data: Data(image.activityImage.data.readableBytesView),
                        filename: tempFileName
                    )
                    fileName = tempFileName
                } catch {
                    return request.redirect(to: "/admin?page=activities")
                }
            }

            activity.title = input.title
            activity.subtitle = input.subtitle
            activity.description = input.description
            activity.metadataURL = input.metadataURL
            activity.image = fileName

            activity.$event.id = try event.requireID()

            try await activity.update(on: request.db)
        } else {
            var fileName: String?

            if !image.activityImage.filename.isEmpty {
                fileName = "\(UUID.generateRandom().uuidString)-\(image.activityImage.filename)"

                do {
                    try await ImageService.uploadFile(
                        data: Data(image.activityImage.data.readableBytesView),
                        filename: fileName!
                    )
                } catch {
                    return request.redirect(to: "/admin?page=activities")
                }
            }

            let activity = Activity(
                id: .generateRandom(),
                title: input.title,
                subtitle: input.subtitle,
                description: input.description,
                metadataURL: input.metadataURL,
                image: fileName
            )

            activity.$event.id = try event.requireID()

            try await activity.create(on: request.db)
        }

        return request.redirect(to: "/admin?page=activities")
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
        let subtitle: String?
        let description: String?
        let metadataURL: String?
    }

    // MARK: - ImageUpload
    struct ImageUpload: Content {
        var activityImage: File
    }
}
