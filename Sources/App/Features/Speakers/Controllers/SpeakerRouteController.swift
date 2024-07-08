import Fluent
import Foundation
import S3
import Vapor

struct SpeakerRouteController: RouteCollection {
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
        let speaker = try await request.parameters.get("id").map { Speaker.find($0, on: request.db) }?.get()
        let context = SpeakerContext(speaker: speaker)
        return try await request.view.render("Admin/Form/speaker_form", context)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let speaker = try await Speaker.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        try await speaker.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }
    
    @Sendable private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, speaker: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let speaker = try await Speaker.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await update(request: request, speaker: speaker)
    }

    private func update(request: Request, speaker: Speaker?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpload.self)
        var imageFilename = speaker?.profileImage ?? ""

        if image.profileImage.filename != "" {
            imageFilename = "\(UUID.generateRandom().uuidString)-\(image.profileImage.filename)"

            try await ImageService.uploadFile(
                data: Data(image.profileImage.data.readableBytesView),
                filename: imageFilename
            )
        }
        
        let mutableSpeaker = speaker ?? Speaker()
        mutableSpeaker.name = input.name
        mutableSpeaker.biography = input.biography
        mutableSpeaker.profileImage = imageFilename
        mutableSpeaker.organisation = input.organisation
        mutableSpeaker.twitter = input.twitter?.trimToNil?
            .replacingOccurrences(of: "https://twitter.com/", with: "")
            .replacingOccurrences(of: "https://x.com/", with: "")
        mutableSpeaker.linkedin = input.linkedin?.trimToNil?
            .replacingOccurrences(of: "https://linkedin.com/in/", with: "")
        mutableSpeaker.website = input.website?.trimToNil
        mutableSpeaker.github = input.github?.trimToNil?
            .replacingOccurrences(of: "https://github.com/", with: "")
        mutableSpeaker.mastodon = input.mastodon?.trimToNil
        
        if speaker != nil {
            try await mutableSpeaker.update(on: request.db)
        } else {
            mutableSpeaker.id = .generateRandom()
            try await mutableSpeaker.create(on: request.db)
        }

        return Response(status: .ok, body: .init(string: "OK"))
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
        let linkedin: String?
        let website: String?
        let github: String?
        let mastodon: String?
    }
}

extension String {
    var trimToNil: String? {
        let trim = trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trim.isEmpty {
            return nil
        }
        
        return trim
    }
}
