import Fluent
import Vapor

struct SlotAPIController: RouteCollection {
    private struct FormInput: Content {
        let presentationID: String?
        let activityID: String?
        let eventID: String
        let startTime: String
        let duration: Double
        let type: String
    }

    enum FormError: Error {
        case didNotProvideActivityOrPresentation
    }

    func boot(routes: RoutesBuilder) throws {
        routes.post(use: onPost)
        routes.post(":id", use: onEdit)
    }

    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }

        var activity: Activity?
        var presentation: Presentation?

        // We can have either, but not both. If both are provided, prioritise the activity.
        if let activityID = input.activityID {
            activity = try await Activity.find(.init(uuidString: activityID), on: request.db)
        } else if let presentationID = input.presentationID {
            presentation = try await Presentation.find(.init(uuidString: presentationID), on: request.db)
        }

        guard activity != nil || presentation != nil else {
            throw FormError.didNotProvideActivityOrPresentation
        }

        let slot = Slot(
            id: .generateRandom(),
            startDate: input.startTime,
            duration: input.duration
        )

        slot.$event.id = try event.requireID()

        try await slot.create(on: request.db)

        if let activity = activity {
            activity.$slot.id = try slot.requireID()
            try await activity.update(on: request.db)
        } else if let presentation = presentation {
            presentation.$slot.id = try slot.requireID()
            try await presentation.update(on: request.db)
        }

        return request.redirect(to: "/admin?page=slots")
    }

    private func onEdit(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)

        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            return request.redirect(to: "/admin")
        }

        guard let slot = try await Slot.find(request.parameters.get("id"), on: request.db) else {
            return request.redirect(to: "/admin")
        }

        // Load children relationships
        try await slot.$presentation.load(on: request.db)
        try await slot.$activity.load(on: request.db)

        var activity: Activity?
        var presentation: Presentation?

        // We can have either, but not both. If both are provided, prioritise the activity.
        if let activityID = input.activityID {
            activity = try await Activity.find(.init(uuidString: activityID), on: request.db)
        } else if let presentationID = input.presentationID {
            presentation = try await Presentation.find(.init(uuidString: presentationID), on: request.db)
        }

        guard activity != nil || presentation != nil else {
            throw FormError.didNotProvideActivityOrPresentation
        }

        slot.startDate = input.startTime
        slot.duration = input.duration
        slot.$event.id = try event.requireID()

        try await slot.update(on: request.db)

        if let activity = activity, activity.id != slot.activity?.id {
            activity.$slot.id = try slot.requireID()
            try await activity.update(on: request.db)
        } else if let presentation = presentation, presentation.id != slot.presentation?.id {
            presentation.$slot.id = try slot.requireID()
            try await presentation.update(on: request.db)
        }

        return request.redirect(to: "/admin?page=slots")
    }
}
