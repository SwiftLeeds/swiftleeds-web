import Fluent
import Vapor

struct SlotRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onShowCreate)
        routes.get(":id", use: onShowEdit)
        routes.get("delete", ":id", use: onDelete)
        routes.post(use: onCreate)
        routes.post(":id", use: onEdit)
    }

    private func onShowCreate(request: Request) async throws -> View {
        try await showForm(request: request, slot: nil)
    }

    private func onShowEdit(request: Request) async throws -> View {
        guard let slot = try await Slot.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }

        try await slot.$presentation.load(on: request.db)
        try await slot.$activity.load(on: request.db)

        return try await showForm(request: request, slot: slot)
    }

    private func showForm(request: Request, slot: Slot?) async throws -> View {
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

    private func onDelete(request: Request) async throws -> Response {
        guard let requestID = request.parameters.get("id") else {
            throw Abort(.notFound)
        }

        guard let slot = try? await Slot.find(.init(uuidString: requestID), on: request.db) else {
            throw Abort(.notFound)
        }

        try await slot.delete(on: request.db)

        return request.redirect(to: "/admin?page=slots")
    }

    private func onCreate(request: Request) async throws -> Response {
        try await update(request: request, slot: nil)
    }

    private func onEdit(request: Request) async throws -> Response {
        guard let slot = try await Slot.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin?page=slots")
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
            return request.redirect(to: "/admin?page=slots")
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

        return request.redirect(to: "/admin?page=slots")
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
