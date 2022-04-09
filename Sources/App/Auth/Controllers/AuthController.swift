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
        routes.get("logout", use: logout)
        let grouped = routes.grouped("api", "v1", "auth")
        grouped.post("create", use: create)
        
        let passwordProtected = grouped.grouped(
            [
                User.authenticator(),
                User.credentialsAuthenticator(),
                User.sessionAuthenticator()
            ]
        )
        
        passwordProtected.post("login", use: login)
    }
    
    private func create(request: Request) async throws -> UserToken {
        try User.Create.validate(content: request)
        let newUser = try request.content.decode(User.Create.self)
        guard newUser.password == newUser.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        let user = try User(name: newUser.name,
                            email: newUser.email.lowercased(),
                            passwordHash: Bcrypt.hash(newUser.password),
                            role: User.Role.user) // by default you're a user
        let token = try user.generateToken()
        try await user.save(on: request.db)
        try await token.save(on: request.db)
        return token
    }
    
    private func login(request: Request) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            throw Abort(.notFound)
        }
                
        do {
            let token = try user.generateToken()
            try await token.save(on: request.db)
            return request.redirect(to: "/")
        } catch {
            guard let old = try await user.$token.get(on: request.db) else {
                throw error
            }
            
            guard old.isValid else {
                try await old.delete(on: request.db)
                return try await login(request: request)
            }
            return request.redirect(to: "/")
        }
    }
    
    private func logout(request: Request) async throws -> Response {
        guard let user = request.auth.get(User.self) else {
            return request.redirect(to: "/")
        }
        
        guard let token = try await user.$token.get(on: request.db) else {
            return request.redirect(to: "/")
        }
        
        try await token.delete(on: request.db)
        request.auth.logout(User.self)
        return request.redirect(to: "/")
    }
}
