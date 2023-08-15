import Fluent
import Vapor

struct SponsorRouteController: RouteCollection {
    private let sponsorLevels: [Sponsor.SponsorLevel] = [.silver, .gold, .platinum]

    private struct SponsorContext: Content {
        let sponsor: Sponsor?
        let sponsorLevels: [Sponsor.SponsorLevel]
        let events: [Event]
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }

    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, sponsor: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let sponsor = try await Sponsor.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await showForm(request: request, sponsor: sponsor)
    }

    private func showForm(request: Request, sponsor: Sponsor?) async throws -> View {
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = SponsorContext(sponsor: sponsor, sponsorLevels: sponsorLevels, events: events)

        return try await request.view.render("Admin/Form/sponsor_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard let sponsor = try await Sponsor.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }

        try await sponsor.delete(on: request.db)
        return request.redirect(to: "/admin?page=sponsors")
    }
    
    private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, sponsor: nil)
    }
    
    private func onEdit(request: Request) async throws -> Response {
        guard let sponsor = try await Sponsor.find(
            request.parameters.get("id"), on: request.db
        ) else {
            return request.redirect(to: "/admin?page=sponsors")
        }
        
        return try await update(request: request, sponsor: sponsor)
    }

    private func update(request: Request, sponsor: Sponsor?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageInput.self)

        guard let event = try await Event.find(
            .init(uuidString: input.eventID), on: request.db
        ) else {
            return request.redirect(to: "/admin?page=sponsors")
        }

        var imageFilename = sponsor?.image ?? ""

        if let sponsorImage = image.sponsorImage, sponsorImage.filename != "" {
            imageFilename = "\(UUID.generateRandom().uuidString)-\(sponsorImage.filename)"

            do {
                try await ImageService.uploadFile(
                    data: Data(sponsorImage.data.readableBytesView),
                    filename: imageFilename
                )
            } catch {
                return request.redirect(to: "/admin?page=sponsors")
            }
        }

        guard let sponsorLevel = Sponsor.SponsorLevel(rawValue: input.sponsorLevel) else {
            return request.redirect(to: "/admin?page=sponsors")
        }

        if let sponsor {
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

        return request.redirect(to: "/admin?page=sponsors")
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
}
