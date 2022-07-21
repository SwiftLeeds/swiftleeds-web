import Vapor
import Fluent

struct SponsorAPIController: RouteCollection {
    
    private struct ImageCreateInput: Content {
        let sponsorImage: File
    }
    
    private struct ImageUpdateInput: Content {
        let sponsorImage: File?
    }
    
    private struct FormInput: Content {
        let name: String
        let url: String
        let sponsorLevel: String
        let eventID: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.post("", use: onPost)
        routes.post(":id", use: onEdit)
    }
    
    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageCreateInput.self)
        
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
    
    private func onEdit(request: Request) async throws -> Response {
        guard let sponsor = try await Sponsor.find(
            request.parameters.get("id"),
            on: request.db
        ) else {
            return request.redirect(to: "/admin")
        }
        
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageUpdateInput.self)
        
        guard let event = try await Event.find(
            .init(uuidString: input.eventID),
            on: request.db
        ) else {
            return request.redirect(to: "/admin")
        }
        
        var fileName = sponsor.image
        
        if let sponsorImage = image.sponsorImage, !sponsorImage.filename.isEmpty {
            let tempFileName = "\(UUID.generateRandom().uuidString)-\(sponsorImage.filename)"
            
            do {
                try await ImageService.uploadFile(
                    data: Data(sponsorImage.data.readableBytesView),
                    filename: tempFileName
                )
                
                fileName = tempFileName
            } catch {
                return request.redirect(to: "/admin")
            }
        }
        
        guard let sponsorLevel = Sponsor.SponsorLevel(rawValue: input.sponsorLevel) else {
            return request.redirect(to: "/admin")
        }
        
        sponsor.name = input.name
        sponsor.image = fileName
        sponsor.url = input.url
        sponsor.sponsorLevel = sponsorLevel
        sponsor.$event.id = try event.requireID()
        
        try await sponsor.update(on: request.db)
        
        return request.redirect(to: "/admin?page=sponsors")
    }
}
