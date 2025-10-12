import Fluent
import Vapor

struct ScheduleAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable private func onGet(request: Request) async throws -> Response {
        let events = try await Event
            .query(on: request.db)
            .all()

        guard let event = events.first(where: { $0.shouldBeReturned(by: request) }) else {
            throw ScheduleAPIController.ScheduleAPIError.notFound
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

        guard let schedule = ScheduleTransformer.transform(event: event, events: events, slots: event.showSchedule ? slots : []) else {
            throw ScheduleAPIController.ScheduleAPIError.transformFailure
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
