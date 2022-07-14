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
        var activityImage: File
    }

    func boot(routes: RoutesBuilder) throws {
        routes.post("", use: onPost)
        routes.post(":id", use: onEdit)
    }

    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }

        // Image upload
        let data =  Data(input.activityImage.data.readableBytesView)
        let filename = "\(input.activityImage.filename)-\(UUID.generateRandom().uuidString)"

        let putObjectRequest = S3.PutObjectRequest(acl: .publicRead,
                                                   body: data,
                                                   bucket: "swiftleeds-speakers",
                                                   contentLength: Int64(data.count),
                                                   key: filename
        )
        let s3 = S3(accessKeyId: Environment.get("S3_KEY")!,
                    secretAccessKey: Environment.get("S3_SECRET")!,
                    region: .euwest2
        )
        let response = s3.putObject(putObjectRequest)

        // Model

        let activity = Activity(
            id: .generateRandom(),
            title: input.title,
            subtitle: input.subtitle,
            description: input.description,
            metadataURL: input.metadataURL,
            image: filename
        )

        activity.$event.id = try event.requireID()

        try await activity.create(on: request.db)

        return request.redirect(to: "/admin?page=activities")
    }

    private func onEdit(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        guard let activity = try await Activity.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=activities")
        }

        // Image upload
        let data =  Data(input.activityImage.data.readableBytesView)
        let filename = "\(input.activityImage.filename)-\(UUID.generateRandom().uuidString)"

        let putObjectRequest = S3.PutObjectRequest(acl: .publicRead,
                                                   body: data,
                                                   bucket: "swiftleeds-speakers",
                                                   contentLength: Int64(data.count),
                                                   key: filename
        )
        let s3 = S3(accessKeyId: Environment.get("S3_KEY")!,
                    secretAccessKey: Environment.get("S3_SECRET")!,
                    region: .euwest2
        )
        let response = s3.putObject(putObjectRequest)

        // Model


        activity.title = input.title
        activity.subtitle = input.subtitle
        activity.description = input.description
        activity.metadataURL = input.metadataURL

        activity.$event.id = try event.requireID()

        try await activity.update(on: request.db)

        return request.redirect(to: "/admin?page=activities")
    }
}
