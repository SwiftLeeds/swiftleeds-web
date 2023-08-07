import Fluent
import Vapor

struct SponsorAPIController: RouteCollection {
    private struct ImageCreateInput: Content {
        let sponsorImage: File
    }
    
    private struct ImageUpdateInput: Content {
        let sponsorImage: File?
    }
    
    private struct FormInput: Content {
        let name: String
        let subtitle: String
        let url: String
        let sponsorLevel: String
        let eventID: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
        routes.post(use: onPost)
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
            subtitle: input.subtitle,
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
        sponsor.subtitle = input.subtitle
        sponsor.image = fileName
        sponsor.url = input.url
        sponsor.sponsorLevel = sponsorLevel
        sponsor.$event.id = try event.requireID()
        
        try await sponsor.update(on: request.db)
        
        return request.redirect(to: "/admin?page=sponsors")
    }

    private static var readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

    private func onGet(request: Request) async throws -> Response {
        let lastModified = try await LastUpdated
            .query(on: request.db)
            .first()?.sponsors ?? Date.distantPast

        var headers: HTTPHeaders = [:]

        let eTag = try await generateETag(on: request, lastModified: lastModified)
        headers.replaceOrAdd(name: .eTag, value: eTag)

        let lastModifiedString = Self.readableDateFormatter.string(from: lastModified)
        headers.replaceOrAdd(name: .lastModified, value: lastModifiedString)

        if eTag == request.headers.first(name: .ifNoneMatch) {
            return Response(status: .notModified, version: .http1_1, headers: headers, body: .empty)
        }

        let allSponsors = try await Sponsor.query(on: request.db)
            .with(\.$event)
            .all()
            .filter { $0.event.shouldBeReturned(by: request) }

        let sponsorsResponse = try await GenericResponse(
            data: allSponsors.compactMap(SponsorTransformer.transform(_:))
        ).encodeResponse(status: .ok, headers: headers, for: request)

        updateSponsorsHash(on: request, lastModified: lastModified, contentLength: sponsorsResponse.body.count, eTag: eTag)

        return sponsorsResponse
    }

    private func generateETag(on request: Request, lastModified: Date) async throws -> String {
        if
            let hash = request.application.storage[SponsorsHashes.self],
            hash.lastModified == lastModified {
            return hash.eTag
        }

        let timestamp = String(lastModified.timeIntervalSince1970)
        let digest = SHA256.hash(data: timestamp.data(using: .utf8)!)
        return digest.hex
    }

    private func updateSponsorsHash(on request: Request, lastModified: Date, contentLength: Int, eTag: String) {
        request.application.storage[SponsorsHashes.self] = SponsorsHashes.Hash(lastModified: lastModified, contentLength: contentLength, eTag: eTag)
    }

    // MARK: - SponsorsHashes
    struct SponsorsHashes: StorageKey {
        typealias Value = Hash

        struct Hash {
            let lastModified: Date
            let contentLength: Int
            let eTag: String
        }
    }
}
