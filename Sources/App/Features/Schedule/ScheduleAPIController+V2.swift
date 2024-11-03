import Fluent
import Vapor

struct ScheduleAPIControllerV2: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable private func onGet(request: Request) async throws -> Response {
        let events = try await Event
            .query(on: request.db)
            .all()

        guard let event = events.first(where: { $0.shouldBeReturned(by: request) }) else {
            throw ScheduleAPIControllerV2.ScheduleAPIError.notFound
        }

        let slots = try await Slot.query(on: request.db)
            .with(\.$day) {
                $0.with(\.$event)
            }
            .with(\.$activity)
            .with(\.$presentation) { presentation in
                presentation.with(\.$speaker).with(\.$secondSpeaker)
            }
            .all()
            .filter { $0.day?.event.id == event.id }

        guard let schedule = ScheduleTransformerV2.transform(event: event, events: events, slots: event.showSchedule ? slots : []) else {
            throw ScheduleAPIControllerV2.ScheduleAPIError.transformFailure
        }

        let response = GenericResponse(
            data: schedule
        )

        return try await response.encodeResponse(for: request)
    }
}

extension ScheduleAPIControllerV2 {
    enum ScheduleAPIError: Error {
        case notFound
        case transformFailure
    }
}
