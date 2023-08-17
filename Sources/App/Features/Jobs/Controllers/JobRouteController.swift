import Fluent
import Vapor

struct JobRouteController: RouteCollection {
    private struct JobContext: Content {
        let job: Job?
        let sponsors: [Sponsor]
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)

        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }

    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, job: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let job = try await Job.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        return try await showForm(request: request, job: job)
    }

    private func showForm(request: Request, job: Job?) async throws -> View {
        let sponsors = try await Sponsor.query(on: request.db).sort(\.$name).all()
        let context = JobContext(job: job, sponsors: sponsors)

        return try await request.view.render("Admin/Form/job_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard let job = try await Job.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await job.delete(on: request.db)
        return request.redirect(to: "/admin?page=jobs")
    }

    private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, job: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let job = try await Job.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=jobs")
        }

        return try await update(request: request, job: job)
    }

    private func update(request: Request, job: Job?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let sponsor = try await Sponsor.find(.init(uuidString: input.sponsorID), on: request.db) else {
            return request.redirect(to: "/admin?page=jobs")
        }

        if let job = job {
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
                url: input.url
            )

            job.$sponsor.id = try sponsor.requireID()
            try await job.create(on: request.db)
        }

        return request.redirect(to: "/admin?page=jobs")
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
