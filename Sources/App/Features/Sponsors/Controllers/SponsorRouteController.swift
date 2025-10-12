import Fluent
import Vapor

struct SponsorRouteController: RouteCollection {
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
        let sponsor = try await request.parameters.get("id").map { Sponsor.find($0, on: request.db) }?.get()
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = SponsorContext(sponsor: sponsor, sponsorLevels: sponsorLevels, events: events)

        return try await request.view.render("Admin/Form/sponsor_form", context)
    }
    
    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let sponsor = try await Sponsor.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        try await sponsor.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }
    
    @Sendable private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, sponsor: nil)
    }
    
    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let sponsor = try await Sponsor.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Failed to find sponsor")
        }
        
        return try await update(request: request, sponsor: sponsor)
    }

    private func update(request: Request, sponsor: Sponsor?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageInput.self)

        guard let event = try await Event.find(
            .init(uuidString: input.eventID), on: request.db
        ) else {
            throw Abort(.badRequest, reason: "Failed to find event")
        }

        var imageFilename = sponsor?.image ?? ""

        if let sponsorImage = image.sponsorImage, sponsorImage.filename != "" {
            imageFilename = "\(UUID.generateRandom().uuidString)-\(sponsorImage.filename)"

            try await ImageService.uploadFile(
                data: Data(sponsorImage.data.readableBytesView),
                filename: imageFilename
            )
        }

        guard let sponsorLevel = Sponsor.SponsorLevel(rawValue: input.sponsorLevel) else {
            throw Abort(.badRequest, reason: "Failed to map sponsor level")
        }

        if let sponsor = sponsor {
            sponsor.name = input.name
            sponsor.subtitle = input.subtitle
            sponsor.image = imageFilename
            sponsor.url = input.url
            sponsor.sponsorLevel = sponsorLevel
            sponsor.$event.id = try event.requireID()

            try await sponsor.update(on: request.db)
        } else {
            let sponsor = Sponsor(
                id: .generateRandom(),
                name: input.name,
                subtitle: input.subtitle,
                image: imageFilename,
                url: input.url,
                sponsorLevel: sponsorLevel
            )

            sponsor.$event.id = try event.requireID()
            try await sponsor.create(on: request.db)
        }

        return Response(status: .ok, body: .init(string: "OK"))
    }

    // MARK: - SponsorContext
    private struct SponsorContext: Content {
        let sponsor: Sponsor?
        let sponsorLevels: [Sponsor.SponsorLevel]
        let events: [Event]
    }

    // MARK: - ImageInput
    private struct ImageInput: Content {
        let sponsorImage: File?
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let name: String
        let subtitle: String
        let url: String
        let sponsorLevel: String
        let eventID: String
    }

    // MARK: - sponsorLevels
    private let sponsorLevels: [Sponsor.SponsorLevel] = [.silver, .gold, .platinum]
}
