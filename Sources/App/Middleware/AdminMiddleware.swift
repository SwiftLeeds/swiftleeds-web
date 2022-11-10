import Vapor

struct AdminMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let user = request.user else {
            if !request.application.environment.isRelease {
                request.logger.warning("attempted to access admin page, but no user is logged in")
            }
            
            return request.redirect(to: "/login")
        }
        
        guard user.role == .admin else {
            if !request.application.environment.isRelease {
                request.logger.warning("attempted to access admin page, but user does not have admin role")
                // if you see this error, you may need to (manually) update your role in the database to be 'admin'
            }
            
            let message = "Your account does not contain the admin role.".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return request.redirect(to: "/register?message=" + (message ?? ""))
        }
        
        return try await next.respond(to: request)
    }
}
