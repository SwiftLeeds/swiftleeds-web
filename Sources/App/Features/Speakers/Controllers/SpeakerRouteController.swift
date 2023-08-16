import Fluent
import Foundation
import S3
import Vapor

struct SpeakerRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }

    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, speaker: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let speaker = try await Speaker.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await showForm(request: request, speaker: speaker)
    }

    private func showForm(request: Request, speaker: Speaker?) async throws -> View {
        let context = SpeakerContext(speaker: speaker)
        return try await request.view.render("Admin/Form/speaker_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard
            let requestID = request.parameters.get("id"),
            let speaker = try? await Speaker.find(.init(uuidString: requestID), on: request.db)
        else { throw Abort(.notFound) }

        try await speaker.delete(on: request.db)

        return request.redirect(to: "/admin?page=speakers")
    }
    
    private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, speaker: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let speaker = try await Speaker.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await update(request: request, speaker: speaker)
    }

    private func update(request: Request, speaker: Speaker?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)
        var imageFilename = speaker?.profileImage ?? ""

        if image.profileImage.filename != "" {
            imageFilename = "\(UUID.generateRandom().uuidString)-\(image.profileImage.filename)"

            do {
                try await ImageService.uploadFile(
                    data: Data(image.profileImage.data.readableBytesView),
                    filename: imageFilename
                )
            } catch {
                request.logger.error("Speaker could not be created. \(error)")
                return request.redirect(to: "/admin?page=speakers")
            }
        }

        if let speaker {
            speaker.name = input.name
            speaker.biography = input.biography
            speaker.profileImage = imageFilename
            speaker.organisation = input.organisation
            speaker.twitter = input.twitter
            try await speaker.update(on: request.db)
        } else {
            let speaker = Speaker(
                id: .generateRandom(),
                name: input.name,
                biography: input.biography,
                profileImage: imageFilename,
                organisation: input.organisation,
                twitter: input.twitter
            )

            try await speaker.create(on: request.db)
        }

        return request.redirect(to: "/admin?page=speakers")
    }

    // MARK: - ImageUpload
    struct ImageUpload: Content {
        var profileImage: File
    }

    // MARK: - SpeakerContext
    private struct SpeakerContext: Content {
        let speaker: Speaker?
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let name: String
        let biography: String
        let profileImage: String
        let organisation: String
        let twitter: String?
    }
}
