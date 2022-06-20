//
//  EventsController.swift
//
//
//  Created by Joe Williams on 07/06/2022.
//

import Foundation
import Fluent
import Vapor
import Leaf
import LeafKit

struct EventsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("create-event", use: onCreate)
        let grouped = routes.grouped("api", "v1", "events")
        grouped.post("create", use: onPost)
    }
    
    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), presentations: []))
        }
        
        let events = try await Event.query(on: request.db).all()
        let context = EventContext(events: events)
        return try await request.view.render("Authentication/create_events", context)
    }
    
    private func onPost(request: Request) async throws -> Response {
        let customDecoder = URLEncodedFormDecoder(configuration: URLEncodedFormDecoder.Configuration.init(boolFlags: true, arraySeparators: [","], dateDecodingStrategy: .secondsSince1970))
        let event = try request.content.decode(Event.self, using: customDecoder)
        try await event.save(on: request.db)
        return request.redirect(to: "/admin")
    }
}

struct EventContext: Content {
    let events: [Event]
}

struct NowTag: LeafTag {
    struct NowTagError: Error {}

    let formatter = DateFormatter()
    func render(_ ctx: LeafContext) throws -> LeafData {
        formatter.dateFormat = "yyyy-MM-dd"
        guard let string = ctx.parameters[0].double else {
            throw NowTagError()
        }
        
        
        let referenceDate = Date(timeIntervalSince1970: string)

        return LeafData.string(formatter.string(from: referenceDate))
    }
}
