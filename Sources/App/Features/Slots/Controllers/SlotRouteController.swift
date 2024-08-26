import Fluent
import Vapor

struct SlotRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Modal
        routes.get(use: onRead)
        routes.get(":id", use: onRead)
        
        // Form
        routes.post("create", use: onCreate)
        routes.post(":id", "delete", use: onDelete)
        routes.post(":id", "update", use: onUpdate)
    }
    
    @Sendable private func onRead(request: Request) async throws -> View {
        let slot = try await request.parameters.get("id").map { Slot.find($0, on: request.db) }?.get()
        try await slot?.$presentation.load(on: request.db)
        try await slot?.$activity.load(on: request.db)
        
        let context = try await buildContext(from: request.db, slot: slot)
        return try await request.view.render("Admin/Form/slot_form", context)
    }

    private func buildContext(from db: Database, slot: Slot?) async throws -> PresentationContext {
        let eventDays = try await EventDay.query(on: db).with(\.$event).sort(\.$date).all()
        let presentations = try await Presentation.query(on: db).sort(\.$title).all()
        let activities = try await Activity.query(on: db).sort(\.$title).all()
        var initialType = SlotTypes.presentation.rawValue

        if slot?.activity != nil {
            initialType = SlotTypes.activity.rawValue
        }

        return PresentationContext(slot: slot, days: eventDays, presentations: presentations, activities: activities, initialType: initialType)
    }

    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let slot = try await Slot.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        try await slot.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }

    @Sendable private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, slot: nil)
    }

    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let slot = try await Slot.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find slot")
        }

        // Load children relationships
        try await slot.$presentation.load(on: request.db)
        try await slot.$activity.load(on: request.db)

        return try await update(request: request, slot: slot)
    }

    private func update(request: Request, slot: Slot?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        var activity: Activity?
        var presentation: Presentation?

        guard let eventDay = try await EventDay.find(.init(uuidString: input.dayID), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find event day")
        }
        
        try await eventDay.$event.load(on: request.db)
        let event = eventDay.event

        // We can have either, but not both. If both are provided, prioritise the activity.
        if let activityID = input.activityID, activityID.isEmpty == false {
            activity = try await Activity.find(.init(uuidString: activityID), on: request.db)
        } else if let presentationID = input.presentationID, presentationID.isEmpty == false {
            presentation = try await Presentation.find(.init(uuidString: presentationID), on: request.db)
        }

        let minutes: Int = input.startTime.components(separatedBy: ":").enumerated().reduce(into: 0) { builder, value in
            guard let number = Int(value.element) else { return }
            if value.offset == 0 { builder += number * 60 }
            else { builder += number }
        }
        
        let inputDate = eventDay.date.addingTimeInterval(TimeInterval(minutes * 60))
        let duration = input.duration.flatMap(Double.init)
        
        let mutableSlot = slot ?? Slot()
        mutableSlot.startDate = input.startTime
        mutableSlot.date = inputDate
        mutableSlot.duration = duration
        mutableSlot.$event.id = try event.requireID()
        mutableSlot.$day.id = try eventDay.requireID()
        
        if let activity {
            mutableSlot.$activity.id = try activity.requireID()
        } else {
            mutableSlot.$activity.id = nil
        }
        
        if let presentation {
            mutableSlot.$presentation.id = try presentation.requireID()
        } else {
            mutableSlot.$presentation.id = nil
        }
        
        if slot == nil {
            mutableSlot.id = .generateRandom()
            try await mutableSlot.create(on: request.db)
        } else {
            try await mutableSlot.update(on: request.db)
        }
        
        return Response(status: .ok, body: .init(string: "OK"))
    }

    // MARK: - SlotTypes
    enum SlotTypes: String, CaseIterable {
        case presentation
        case activity
    }

    // MARK: - PresentationContext
    private struct PresentationContext: Content {
        let slot: Slot?
        let days: [EventDay]
        let presentations: [Presentation]
        let activities: [Activity]
        let initialType: String
        var types = SlotTypes.allCases.map(\.rawValue)
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let presentationID: String?
        let activityID: String?
        let dayID: String
        let startTime: String
        let duration: String?
        let type: String
    }

    // MARK: - FormError
    enum FormError: Error {
        case didNotProvideActivityOrPresentation
    }
}
