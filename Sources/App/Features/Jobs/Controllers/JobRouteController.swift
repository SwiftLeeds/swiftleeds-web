import Fluent
import Vapor

struct JobRouteController: RouteCollection {
    private struct JobContext: Content {
        let job: Job?
        let sponsors: [Sponsor]
    }

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
        let job = try await request.parameters.get("id").map { Job.find($0, on: request.db) }?.get()
        let sponsors = try await Sponsor.query(on: request.db).sort(\.$name).with(\.$event).all()
        let context = JobContext(job: job, sponsors: sponsors)

        return try await request.view.render("Admin/Form/job_form", context)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let job = try await Job.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }
        try await job.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, job: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let job = try await Job.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find job")
        }

        return try await update(request: request, job: job)
    }

    private func update(request: Request, job: Job?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let sponsor = try await Sponsor.find(.init(uuidString: input.sponsorID), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find sponsor")
        }

        if let job {
            job.title = input.title
            job.location = input.location
            job.details = input.details
            job.url = input.url
            job.$sponsor.id = try sponsor.requireID()
            try await job.update(on: request.db)
        } else {
            let job = Job(id: .generateRandom(),
                          title: input.title,
                          location: input.location,
                          details: input.details,
                          url: input.url)

            job.$sponsor.id = try sponsor.requireID()
            try await job.create(on: request.db)
        }

        return Response(status: .ok, body: .init(string: "OK"))
    }

    // MARK: - FormInput

    private struct FormInput: Content {
        let title: String
        let location: String
        let details: String
        let url: String
        let sponsorID: String
    }
}
