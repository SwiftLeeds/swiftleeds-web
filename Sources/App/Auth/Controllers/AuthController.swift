//
//  AuthController.swift
//  
//
//  Created by Joe Williams on 14/11/2021.
//

import Foundation
import Vapor
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("create", use: create)
        
        let passwordProtected = routes.grouped(AppUser.authenticator())
        passwordProtected.post("login", use: login)
        
        let adminProtected = routes.grouped(AdminAuthenticatable())
        adminProtected.get("admin", use: admin)
    }
    
    private func create(request: Request) throws -> EventLoopFuture<UserToken> {
        try AppUser.Create.validate(content: request)
        let newUser = try request.content.decode(AppUser.Create.self)
        guard newUser.password == newUser.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        let user = try AppUser(name: newUser.name,
                               email: newUser.email,
                               passwordHash: Bcrypt.hash(newUser.password),
                               role: AppUser.UserRole.user) // by default you're a user
        
        
        // we first save the user
        return user.save(on: request.db).flatMapThrowing { _ in
            // we generate a token set and save it
            let token = try user.generateToken()
            _ = token.save(on: request.db)
            // the client is returns that token set to access other api's
            return token
        }
    }
    
    private func login(request: Request) throws -> EventLoopFuture<UserToken> {
        let user = try request.auth.require(AppUser.self)
        let token = try user.generateToken()
        return token.save(on: request.db).flatMapThrowing { _ in
            return token
        }
    }
    
    private func admin(request: Request) throws -> String {
        return "Hello Admin!"
    }
}
