import Vapor
import Fluent

struct SponsorAPIController: RouteCollection {
    
    private struct ImageInput: Content {
        let sponsorImage: File
    }
    
    private struct FormInput: Content {
        let name: String
        let url: String
        let sponsorLevel: String
        let eventID: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("", use: onPost)
    }
    
    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageInput.self)
        
        guard let event = try await Event.find(
            .init(uuidString: input.eventID),
            on: request.db
        ) else {
            return request.redirect(to: "/admin")
        }
        
        let fileName = "\(UUID.generateRandom().uuidString)-\(image.sponsorImage.filename)"
        
        do {
            try await ImageService.uploadFile(
                data: Data(image.sponsorImage.data.readableBytesView),
                filename: fileName
            )
        } catch {
            return request.redirect(to: "/admin")
        }
        
        guard let sponsorLevel = Sponsor.SponsorLevel(rawValue: input.sponsorLevel) else {
            return request.redirect(to: "/admin")
        }
        
        let sponsor = Sponsor(
            id: .generateRandom(),
            name: input.name,
            image: fileName,
            url: input.url,
            sponsorLevel: sponsorLevel
        )

        sponsor.$event.id = try event.requireID()
        
        try await sponsor.create(on: request.db)
        
        return request.redirect(to: "/admin?page=sponsors")
    }
}
