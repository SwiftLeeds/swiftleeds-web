//
//  PresentationController.swift
//  
//
//  Created by Joe Williams on 07/06/2022.
//

import Foundation
import Fluent
import Vapor
import S3

struct PresentationController: RouteCollection {
    
    struct FormInput: Content {
        let speaker: String
        let event: String
        let title: String
        let synopsis: String
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("create-presentation", use: onCreate)
        let grouped = routes.grouped("api", "v1", "presentation")
        grouped.post("create", use: onPost)
    }
    
    private func onCreate(request: Request) async throws -> View {
        guard request.user?.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        
        let speakers = try await Speaker.query(on: request.db).all()
        let events = try await Event.query(on: request.db).all()
        let context = PresentationContext(speakers: speakers, events: events)
        return try await request.view.render("Authentication/create_presentation", context)
    }
    
    private func onPost(request: Request) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        guard let speaker = try await Speaker.find(UUID(uuidString: input.speaker), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        guard let event = try await Event.find(.init(uuidString: input.event), on: request.db) else {
            return request.redirect(to: "/admin")
        }
        
        guard let eventID = event.id else {
            return request.redirect(to: "/admin")
        }
        
        let presentation = Presentation(id: .generateRandom(),
                                        title: input.title,
                                        synopsis: input.synopsis,
                                        image: nil,
                                        eventID: eventID
        )
        
        presentation.$speaker.id = try speaker.requireID()
        presentation.$event.id = try event.requireID()
        try await presentation.create(on: request.db)
        return request.redirect(to: "/admin")
    }
}

struct PresentationContext: Content {
    let speakers: [Speaker]
    let events: [Event]
}
