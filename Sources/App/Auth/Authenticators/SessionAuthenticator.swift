//
//  SessionAuthenticator.swift
//  
//
//  Created by Joe Williams on 09/04/2022.
//

import Foundation
import Vapor
import Fluent

/// Session Authenticator used for checking the auth status of front-end web clients. This authenticator uses the sessions cookie.
class SessionAuthenticator: Authenticator, AsyncSessionAuthenticator {
    typealias User = App.User
    
    func authenticate(sessionID: User.SessionID, for request: Request) async throws {
        guard let user = try await User.query(on: request.db).filter(\.$id == sessionID).first() else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
    }
}
