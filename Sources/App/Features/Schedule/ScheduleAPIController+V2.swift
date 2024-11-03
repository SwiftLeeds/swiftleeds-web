import Fluent
import Vapor

// With the V1 API, clients were expected to infer days from the fact the slot date was different.
//
// With the V2 API (which this file introduces), we add 'Days' as a native concept.
// The enhancements here ensure the application understands how many days there are,
// what slots are on what day, and what the name of the day is (such as 'Talkshow').
struct ScheduleAPIControllerV2: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable private func onGet(request: Request) async throws -> Response {
        let events = try await Event
            .query(on: request.db)
            .with(\.$days)
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

        guard let schedule = ScheduleTransformerV2.transform(event: event, events: events, slots: event.showSchedule ? slots : []) else {
            throw ScheduleAPIController.ScheduleAPIError.transformFailure
        }

        let response = GenericResponse(
            data: schedule
        )

        return try await response.encodeResponse(for: request)
    }
}
