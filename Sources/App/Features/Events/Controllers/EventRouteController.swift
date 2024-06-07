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
        
        routes.post("create", use: onCreate)
        routes.post(":id", "delete", use: onDelete)
        routes.post(":id", "update", use: onEdit)
    }
    
    @Sendable private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, event: nil)
    }

    @Sendable private func onShowEdit(request: Request) async throws -> View {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        return try await showForm(request: request, event: event)
    }

    private func showForm(request: Request, event: Event?) async throws -> View {
        let context = EventContext(event: event)
        return try await request.view.render("Admin/Form/event_form", context)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await event.delete(on: request.db)

        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, event: nil)
    }

    @Sendable private func onEdit(request: Request) async throws -> Response {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Failed to find event")
        }

        return try await update(request: request, event: event)
    }

    private func update(request: Request, event: Event?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let isCurrent = input.isCurrent ?? false
        var eventID: Event.IDValue

        guard let date = Self.formDateFormatter().date(from: input.date) else {
            throw Abort(.badRequest, reason: "Invalid Date Format")
        }

        if let event = event {
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

        return Response(status: .ok, body: .init(string: "OK"))
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
