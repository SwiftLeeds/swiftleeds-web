import Fluent
import Fluent
import Foundation
import Leaf
import LeafKit
import Vapor

struct EventRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }
    
    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, event: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        return try await showForm(request: request, event: event)
    }

    private func showForm(request: Request, event: Event?) async throws -> View {
        let context = EventContext(event: event)
        return try await request.view.render("Admin/Form/event_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await event.delete(on: request.db)

        return request.redirect(to: "/admin?page=events")
    }

    private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, event: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=events")
        }

        return try await update(request: request, event: event)
    }

    private func update(request: Request, event: Event?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let isCurrent = input.isCurrent ?? false
        var eventID: Event.IDValue

        guard let date = Self.formDateFormatter().date(from: input.date) else { return request.redirect(to: "/admin?page=events")}

        if let event {
            event.name = input.name
            event.date = date
            event.location = input.location
            event.isCurrent = isCurrent

            eventID = try event.requireID()

            try await event.update(on: request.db)
        } else {
            let event = Event(
                id: .generateRandom(),
                name: input.name,
                date: date,
                location: input.location,
                isCurrent: isCurrent
            )

            eventID = try event.requireID()

            try await event.create(on: request.db)
        }

        if isCurrent {
            // Unset all other events if this is now Current
            try await Event
                .query(on: request.db)
                .set(\.$isCurrent, to: false)
                .filter(\.$id != eventID)
                .update()
        }

        return request.redirect(to: "/admin?page=events")
    }

    // MARK: - EventContext
    private struct EventContext: Content {
        let event: Event?
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let name: String
        let date: String
        let location: String
        let isCurrent: Bool?
    }
}
