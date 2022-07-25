//
//  ScheduleAPIController.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Vapor
import Fluent


struct ScheduleAPIController: RouteCollection {
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
                        presentation.with(\.$speaker)
                    })

            })
            .first()

        var data = (eventWithSlots?.slots.compactMap(SlotTransformer.transform) ?? [])
        data.sort(using: KeyPathComparator(\.startTime, order: .forward))
        return try await GenericResponse(
            data: data
        ).encodeResponse(for: request)
    }
}