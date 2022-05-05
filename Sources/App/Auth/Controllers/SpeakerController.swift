//
//  File.swift
//  
//
//  Created by Joe Williams on 09/04/2022.
//

import Foundation
import Fluent
import Vapor

struct SpeakerController: RouteCollection {
    
    struct ImageUpload: Content {
        var profileImage: File
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("create-speaker", use: onCreate)
        let grouped = routes.grouped("api", "v1", "speaker")
        grouped.post("create", use: onPostCreate)
    }
    
    private func onPostCreate(request: Request) async throws -> Response {
        let speaker = try request.content.decode(Speaker.self)
        let image = try request.content.decode(ImageUpload.self)
        
        let app = request.application
        let filename = "\(image.profileImage.filename)-\(UUID.generateRandom().uuidString)"
        let path = app.directory.publicDirectory + "img/\(filename)"
        try await request.fileio.writeFile(image.profileImage.data, at: path)
        speaker.profileImage = filename
        try await speaker.save(on: request.db)
        return request.redirect(to: "/admin?page=speakers")
    }
    
    private func onCreate(request: Request) async throws -> View {
        guard let user = request.auth.get(User.self), user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }

        return try await request.view.render("Authentication/create_speaker")
    }
}
