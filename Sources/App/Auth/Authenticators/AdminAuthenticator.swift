//
//  File.swift
//  
//
//  Created by Joe Williams on 16/11/2021.
//

import Foundation
import Vapor
import Fluent

class AdminAuthenticatable: AsyncBearerAuthenticator {
    
    enum RoleFailure: Error {
        case notAuthenticated
        case notAdmin
    }
    
    func authenticate(bearer: BearerAuthorization, for request: Request) async throws {
        guard let token = try await UserToken.query(on: request.db).filter(\.$value == bearer.token).first() else {
            throw Abort(.unauthorized)
        }
        
        guard token.isValid else {
            try await token.delete(force: true, on: request.db)
            throw Abort(.unauthorized)
        }
        
        let user = try await token.$user.get(on: request.db)
        guard user.role == .admin else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(token)
        request.auth.login(user)
    }
}
