import Fluent
import Vapor

struct SlotViewController: RouteCollection {
    enum SlotTypes: String, CaseIterable {
        case presentation
        case activity
    }

    private struct PresentationContext: Content {
        let slot: Slot?
        let events: [Event]
        let presentations: [Presentation]
        let activities: [Activity]
        let initialType: String
        var types = SlotTypes.allCases.map(\.rawValue)
    }

    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onCreate)
        routes.get(":id", use: onEdit)
        routes.get("delete", ":id", use: onDelete)
    }

    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        let context = try await buildContext(from: request.db, slot: nil)
        return try await request.view.render("Authentication/slot_form", context)
    }

    private func onEdit(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }

        guard let requestID = request.parameters.get("id") else {
            throw Abort(.notFound)
        }

        guard let slot = try? await Slot.find(.init(uuidString: requestID), on: request.db) else {
            throw Abort(.notFound)
        }

        try await slot.$presentation.load(on: request.db)
        try await slot.$activity.load(on: request.db)

        let context = try await buildContext(from: request.db, slot: slot)
        return try await request.view.render("Authentication/slot_form", context)
    }

    private func onDelete(request: Request) async throws -> Response {
        guard request.user?.role == .admin else {
            return request.redirect(to: "/home")
        }

        guard let requestID = request.parameters.get("id") else {
            throw Abort(.notFound)
        }

        guard let slot = try? await Slot.find(.init(uuidString: requestID), on: request.db) else {
            throw Abort(.notFound)
        }

        try await slot.delete(on: request.db)

        return request.redirect(to: "/admin?page=slots")
    }

    private func buildContext(from db: Database, slot: Slot?) async throws -> PresentationContext {
        let events = try await Event.query(on: db).all()
        let presentations = try await Presentation.query(on: db).all()
        let activities = try await Activity.query(on: db).all()
        var initialType = SlotTypes.presentation.rawValue
        if slot?.activity != nil {
            initialType = SlotTypes.activity.rawValue
        }
        return PresentationContext(slot: slot, events: events, presentations: presentations, activities: activities, initialType: initialType)
    }
}
