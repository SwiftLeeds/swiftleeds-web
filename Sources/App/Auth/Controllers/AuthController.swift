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
    }
    
    private func create(request: Request) async throws -> UserToken {
        try AppUser.Create.validate(content: request)
        let newUser = try request.content.decode(AppUser.Create.self)
        guard newUser.password == newUser.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        let user = try AppUser(name: newUser.name,
                               email: newUser.email,
                               passwordHash: Bcrypt.hash(newUser.password),
                               role: AppUser.UserRole.user) // by default you're a user
        let token = try user.generateToken()
        try await user.save(on: request.db)
        try await token.save(on: request.db)
        return token
    }
    
    private func login(request: Request) async throws -> UserToken {
        let user = try request.auth.require(AppUser.self)
        do {
            let token = try user.generateToken()
            try await token.save(on: request.db)
            return token
        } catch {
            guard let old = try await user.$token.get(on: request.db) else {
                throw error
            }
            
            guard old.isValid else {
                try await old.delete(on: request.db)
                return try await login(request: request)
            }
            
            return old
        }
    }
    
    private func logout(request: Request) async throws {
        let user = try request.auth.require(AppUser.self)
        guard let token = try await user.$token.get(on: request.db) else {
            throw Abort(.unauthorized)
        }
        
        try await token.delete(on: request.db)
    }
}
