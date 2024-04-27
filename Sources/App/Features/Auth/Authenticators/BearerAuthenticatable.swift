import Fluent
import Foundation
import Vapor

/// Authenticator used to authenticate a user by their auth token.
final class BearerAuthenticatable: Authenticator, AsyncBearerAuthenticator {
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
        request.auth.login(token)
        request.auth.login(user)
    }
}
