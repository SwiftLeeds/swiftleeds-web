import Vapor

let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22

func routes(_ app: Application) throws {
    
    let route = app.routes.grouped(User.sessionAuthenticator())
 
    route.get { req -> View in
        do {
            let speakers = try await Speaker.query(on: req.db).all()
            return try await req.view.render("Home/home", HomeContext(speakers: speakers, cfpEnabled: cfpExpirationDate > Date()))
        } catch {
            return try await req.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
    }
    
    app.routes.get("login") { request in
        request.view.render("Authentication/login")
    }
    
    app.routes.get("register") { request in
        request.view.render("Authentication/register")
    }
    
    app.routes.get("admin") { request -> View in
        let query = try request.query.decode(PageQuery.self)
        return try await request.view.render("Admin/home", ["page": query.page])
    }
        
    app.routes.get("create-presentation") { request -> View in
        guard let user = request.auth.get(User.self) else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        
        guard user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date()))
        }
        
        let speakers = try await Speaker.query(on: request.db).all()
        let context = HomeContext(speakers: speakers, cfpEnabled: cfpExpirationDate > Date())
        return try await request.view.render("Authentication/create_presentation", context)
    }
    
    try app.routes.register(collection: AuthController())
    try app.routes.register(collection: SpeakerController())
}

struct PageQuery: Content {
    var page: String
}
