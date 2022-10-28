import Fluent
import Vapor

struct ScheduleAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onGet)
    }

    private func onGet(request: Request) async throws -> Response {
        // Get the current event
        // In future this will need to be smarter
        let eventWithSlots = try await Event.query(on: request.db)
            .sort(\.$date, .ascending)
            .with(\.$slots) { slots in
                slots
                    .with(\.$activity)
                    .with(\.$presentation) { presentation in
                        presentation.with(\.$speaker)
                    }
            }
            .first()

        guard let event = eventWithSlots else {
            throw ScheduleAPIError.notFound
        }

        guard let schedule = ScheduleTransformer.transform(event: event, slots: event.slots) else {
            throw ScheduleAPIError.transformFailure
        }

        let response = GenericResponse(
            data: schedule
        )
        
        return try await response.encodeResponse(for: request)
    }
}

extension ScheduleAPIController {
    enum ScheduleAPIError: Error {
        case notFound
        case transformFailure
    }
}
