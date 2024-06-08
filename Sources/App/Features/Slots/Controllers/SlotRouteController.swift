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
        let events = try await Event.query(on: db).sort(\.$date).all()
        let presentations = try await Presentation.query(on: db).sort(\.$title).all()
        let activities = try await Activity.query(on: db).sort(\.$title).all()
        var initialType = SlotTypes.presentation.rawValue

        if slot?.activity != nil {
            initialType = SlotTypes.activity.rawValue
        }

        return PresentationContext(slot: slot, events: events, presentations: presentations, activities: activities, initialType: initialType)
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

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            throw Abort(.badRequest, reason: "Could not find event")
        }

        // We can have either, but not both. If both are provided, prioritise the activity.
        if let activityID = input.activityID, activityID.isEmpty == false {
            activity = try await Activity.find(.init(uuidString: activityID), on: request.db)
        } else if let presentationID = input.presentationID, presentationID.isEmpty == false {
            presentation = try await Presentation.find(.init(uuidString: presentationID), on: request.db)
        }

        let inputDate = Self.formDateTimeFormatter().date(from: input.date) ?? Date()

        if let slot = slot {
            slot.startDate = Self.timeFormatter().string(from: inputDate)
            slot.date = inputDate
            slot.duration = input.duration
            slot.$event.id = try event.requireID()
            try await slot.update(on: request.db)

            var hasSessionChanged = (slot.activity?.id == nil && slot.presentation?.id == nil)

            // Remove old session reference if changed
            if let existingActivity = slot.activity, input.activityID != existingActivity.id?.uuidString {
                let emptySlotID: Slot.IDValue? = nil
                existingActivity.$slot.id = emptySlotID
                try await existingActivity.update(on: request.db)
                hasSessionChanged = true
            }

            if let existingPresentation = slot.presentation, input.presentationID != existingPresentation.id?.uuidString {
                let emptySlotID: Slot.IDValue? = nil
                existingPresentation.$slot.id = emptySlotID
                try await existingPresentation.update(on: request.db)
                hasSessionChanged = true
            }

            // Add new session reference if required
            if hasSessionChanged {
                if let activity = activity {
                    activity.$slot.id = try slot.requireID()
                    try await activity.update(on: request.db)
                } else if let presentation = presentation {
                    presentation.$slot.id = try slot.requireID()
                    try await presentation.update(on: request.db)
                }
            }
        } else {
            let newSlot = Slot(
                id: .generateRandom(),
                startDate: Self.timeFormatter().string(from: inputDate),
                date: inputDate,
                duration: input.duration
            )

            newSlot.$event.id = try event.requireID()

            try await newSlot.create(on: request.db)

            if let activity = activity {
                activity.$slot.id = try newSlot.requireID()
                try await activity.update(on: request.db)
            } else if let presentation = presentation {
                presentation.$slot.id = try newSlot.requireID()
                try await presentation.update(on: request.db)
            }
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
        let events: [Event]
        let presentations: [Presentation]
        let activities: [Activity]
        let initialType: String
        var types = SlotTypes.allCases.map(\.rawValue)
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let presentationID: String?
        let activityID: String?
        let eventID: String
        let date: String
        let duration: Double
        let type: String
    }

    // MARK: - FormError
    enum FormError: Error {
        case didNotProvideActivityOrPresentation
    }
}
