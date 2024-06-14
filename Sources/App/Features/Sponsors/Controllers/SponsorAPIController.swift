import Fluent
import Vapor

struct SponsorAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable private func onGet(request: Request) async throws -> Response {
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
            .with(\.$jobs)
            .all()
            .filter { $0.event.shouldBeReturned(by: request) }

        let sponsorsResponse = try await GenericResponse(
            data: allSponsors.compactMap(SponsorTransformer.transform)
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

    private static let readableDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

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
