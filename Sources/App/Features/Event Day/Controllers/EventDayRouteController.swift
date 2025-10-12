import Fluent
import Foundation
import Leaf
import LeafKit
import Vapor

struct EventDayRouteController: RouteCollection {
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
        let day = try await request.parameters.get("id").map { EventDay.find($0, on: request.db) }?.get()
        try await day?.$event.load(on: request.db)
        
        let events = try await Event.query(on: request.db).all()
        
        let context = EventDayContext(day: day, events: events)
        return try await request.view.render("Admin/Form/event_day_form", context)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let event = try await EventDay.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.notFound)
        }
        try await event.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, day: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let event = try await EventDay.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Failed to find event")
        }

        return try await update(request: request, day: event)
    }

    private func update(request: Request, day: EventDay?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        
        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find event")
        }
        
        guard let date = Self.formDateFormatter().date(from: input.date) else {
            throw Abort(.badRequest, reason: "Invalid Date Format")
        }
        
        let mutableDay = day ?? EventDay()
        mutableDay.name = input.name
        mutableDay.date = date
        mutableDay.startTime = input.startTime
        mutableDay.endTime = input.endTime
        mutableDay.$event.id = try event.requireID()
        
        if day == nil {
            mutableDay.id = .generateRandom()
            try await mutableDay.create(on: request.db)
        } else {
            try await mutableDay.update(on: request.db)
        }
        
        return Response(status: .ok, body: .init(string: "OK"))
    }

    // MARK: - EventContext

    private struct EventDayContext: Content {
        let day: EventDay?
        let events: [Event]
    }

    // MARK: - FormInput

    private struct FormInput: Content {
        let name: String
        let date: String
        let startTime: String
        let endTime: String
        let eventID: String
    }
}
