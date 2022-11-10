import Fluent
import Foundation
import S3
import Vapor

struct SpeakerController: RouteCollection {
    struct ImageUpload: Content {
        var profileImage: File
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("create-speaker", use: onCreate)
        let grouped = routes.grouped("api", "v1", "speaker")
        grouped.post("create", use: onPostCreate)
    }
    
    private func onPostCreate(request: Request) async throws -> Response {
        let speaker = try request.content.decode(Speaker.self)
        let image = try request.content.decode(ImageUpload.self)
        
        let fileName = "\(image.profileImage.filename)-\(UUID.generateRandom().uuidString)"

        do {
            try await ImageService.uploadFile(
                data: Data(image.profileImage.data.readableBytesView),
                filename: fileName
            )
        } catch {
            return request.redirect(to: "/admin")
        }
        
        speaker.profileImage = fileName
        
        try await speaker.save(on: request.db)
        
        return request.redirect(to: "/admin?page=speakers")
    }
    
    private func onCreate(request: Request) async throws -> View {
        guard let user = request.auth.get(User.self), user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        return try await request.view.render("Authentication/create_speaker")
    }
}
