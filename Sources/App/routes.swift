import Vapor

func routes(_ app: Application) throws {
    
    let route = app.routes.grouped(AppUser.sessionAuthenticator())
    
    route.get { req -> EventLoopFuture<View> in
        let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22
        guard let user = req.auth.get(AppUser.self) else {
            return req.view.render("Home/home")
        }
        return req.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), user: user))
    }
    
    app.routes.get("login") { request in
        request.view.render("Authentication/login")
    }
    
    app.routes.get("register") { request in
        request.view.render("Authentication/register")
    }
    
    try app.routes.register(collection: AuthController())
}
