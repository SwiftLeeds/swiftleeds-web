import Vapor
import Fluent
import S3

struct ActivityAPIController: RouteCollection {
    private struct FormInput: Content {
        let eventID: String
        let title: String
        let subtitle: String?
        let description: String?
        let metadataURL: String?
    }

    struct ImageUpload: Content {
        var activityImage: File
    }

    func boot(routes: RoutesBuilder) throws {
        routes.post("", use: onPost)
        routes.post(":id", use: onEdit)
    }

    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }

        // Image upload
        let fileName = "\(UUID.generateRandom().uuidString)-\(image.activityImage.filename)"

        if !image.activityImage.filename.isEmpty {

            do {
                try await ImageService.uploadFile(
                    data: Data(image.activityImage.data.readableBytesView),
                    filename: fileName
                )
            } catch {
                return request.redirect(to: "/admin?page=activities")
            }
        }

        // Model

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

        return request.redirect(to: "/admin?page=activities")
    }

    private func onEdit(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        // Image upload
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

        // Model
        activity.title = input.title
        activity.subtitle = input.subtitle
        activity.description = input.description
        activity.metadataURL = input.metadataURL
        activity.image = fileName

        activity.$event.id = try event.requireID()

        try await activity.update(on: request.db)

        return request.redirect(to: "/admin?page=activities")
    }
}
