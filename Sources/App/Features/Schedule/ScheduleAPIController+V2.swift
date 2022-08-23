//
//  ScheduleAPIController+V2.swift
//
//
//  Created by Alex Logan on 18/08/2022.
//

import Vapor
import Fluent

struct ScheduleAPIControllerV2: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("", use: onGet)
    }

    private func onGet(request: Request) async throws -> Response {
        // Get the current event
        // In future this will need to be smarter
        let eventWithSlots = try await Event.query(on: request.db)
            .sort(\.$date, .ascending)
            .with(\.$slots, { slots in
                slots
                    .with(\.$activity)
                    .with(\.$presentation, { presentation in
                        presentation.with(\.$speaker).with(\.$secondSpeaker)
                    })
            })
            .first()

        guard let event = eventWithSlots else {
            throw ScheduleAPIController.ScheduleAPIError.notFound
        }

        guard let schedule = ScheduleTransformerV2.transform(event: event, slots: event.slots) else {
            throw ScheduleAPIController.ScheduleAPIError.transformFailure
        }

        let response = GenericResponse(
            data: schedule
        )

        return try await response.encodeResponse(for: request)
    }
}
