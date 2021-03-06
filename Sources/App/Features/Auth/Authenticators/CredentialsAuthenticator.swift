//
//  CustomCredentialsAuthenticator.swift
//  
//
//  Created by Joe Williams on 09/04/2022.
//

import Foundation
import Vapor
import Fluent

/// Credentials Authenticator used for authenticating front-end web clients.
class CustomCredentialsAuthenticator: Authenticator, AsyncCredentialsAuthenticator {
    struct Input: Content {
        let email: String
        let password: String
    }

    typealias Credentials = Input
    
    func authenticate(credentials: Credentials, for request: Request) async throws {
        guard let user = try? await User.query(on: request.db).filter(\.$email == credentials.email.lowercased()).first() else {
            throw Abort(.unauthorized)
        }
        
        guard try user.verify(password: credentials.password) else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
    }
}
