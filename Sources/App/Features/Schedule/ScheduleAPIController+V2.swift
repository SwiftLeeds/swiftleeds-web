import Fluent
import Vapor

struct ScheduleAPIControllerV2: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    private func onGet(request: Request) async throws -> Response {
        guard let event = try await Event
            .query(on: request.db)
            .all()
            .first(where: { $0.shouldBeReturned(by: request) })
        else {
            throw ScheduleAPIController.ScheduleAPIError.notFound
        }
        
        let slots = try await Slot.query(on: request.db)
            .with(\.$event)
            .with(\.$activity)
            .with(\.$presentation) { presentation in
                presentation.with(\.$speaker).with(\.$secondSpeaker)
            }
            .all()
            .filter { $0.event.id == event.id }

        guard let schedule = ScheduleTransformerV2.transform(event: event, slots: slots) else {
            throw ScheduleAPIController.ScheduleAPIError.transformFailure
        }

        let response = GenericResponse(
            data: schedule
        )

        return try await response.encodeResponse(for: request)
    }
}
