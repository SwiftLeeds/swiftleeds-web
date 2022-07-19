import Vapor
import Fluent

struct ActivityViewController: RouteCollection {

    private struct ActivityContext: Content {
        let activity: Activity?
        let events: [Event]
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onCreate)
        routes.get(":id", use: onEdit)
        routes.get("delete", ":id", use: onDelete)
    }

    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        let context = try await buildContext(from: request.db, activity: nil)
        return try await request.view.render("Authentication/activity_form", context)
    }

    private func onEdit(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }

        guard let requestID = request.parameters.get("id") else {
            throw Abort(.notFound)
        }

        guard let activity = try? await Activity.find(.init(uuidString: requestID), on: request.db) else {
            throw Abort(.notFound)
        }

        try await activity.$event.load(on: request.db)

        let context = try await buildContext(from: request.db, activity: activity)
        return try await request.view.render("Authentication/activity_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard request.user?.role == .admin else {
            return request.redirect(to: "/home")
        }

        guard let requestID = request.parameters.get("id") else {
            throw Abort(.notFound)
        }

        guard let activity = try? await Activity.find(.init(uuidString: requestID), on: request.db) else {
            throw Abort(.notFound)
        }

        try await activity.delete(on: request.db)

        return request.redirect(to: "/admin?page=activities")
    }

    private func buildContext(from db: Database, activity: Activity?) async throws -> ActivityContext {
        let events = try await Event.query(on: db).all()
        return ActivityContext(activity: activity, events: events)
    }
}
