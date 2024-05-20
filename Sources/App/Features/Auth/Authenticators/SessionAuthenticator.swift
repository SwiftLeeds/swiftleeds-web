import Fluent
import Foundation
import Vapor

/// Session Authenticator used for checking the auth status of front-end web clients. This authenticator uses the sessions cookie.
final class SessionAuthenticator: Authenticator, AsyncSessionAuthenticator {
    typealias User = App.User
    
    func authenticate(sessionID: User.SessionID, for request: Request) async throws {
        guard let user = try await User.query(on: request.db).filter(\.$id == sessionID).first() else {
            throw Abort(.unauthorized)
        }
        
        request.auth.login(user)
    }
}
