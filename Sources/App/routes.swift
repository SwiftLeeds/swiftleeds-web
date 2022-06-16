import Vapor

let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22


func routes(_ app: Application) throws {
    
    let route = app.routes.grouped(User.sessionAuthenticator())
 
    route.get { req -> View in
        do {
            let speakers = try await Speaker.query(on: req.db).with(\.$presentations).all()
            let presentations = try? await Presentation.query(on: req.db).all()
            return try await req.view.render("Home/home", HomeContext(speakers: speakers, cfpEnabled: cfpExpirationDate > Date(), presentations: presentations ?? []))
        } catch {
            return try await req.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), presentations: []))
        }
    }
    
    app.routes.get("login") { request in
        request.view.render("Authentication/login")
    }
    
    app.routes.get("register") { request -> View in
        if let message = request.query[String.self, at: "message"] {
            return try await request.view.render("Authentication/register", RegisterContext(message: message))
        } else {
            return try await request.view.render("Authentication/register")
        }
    }
    
    app.routes.get("admin") { request -> View in
        guard let user = request.user, user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), presentations: []))
        }
        let query = try? request.query.decode(PageQuery.self)
        let speakers = try await Speaker.query(on: request.db).with(\.$presentations).all()
        let presentations = try await Presentation.query(on: request.db).with(\.$speaker).all()
        let events = try await Event.query(on: request.db).all()
        
        return try await request.view.render("Admin/home", AdminContext(speakers: speakers, presentations: presentations, events: events, page: (query ?? PageQuery(page: "speakers")).page, user: user))
    }
    
    app.get("conduct") { req -> EventLoopFuture<View> in
        return req.view.render("Secondary/conduct", ["name": "Leaf"])
    }
    
    try app.routes.register(collection: AuthController())
    try app.routes.register(collection: SpeakerController())
    try app.routes.register(collection: PresentationController())
    try app.routes.register(collection: EventsController())
}

struct PageQuery: Content {
    var page: String
}

struct AdminContext: Content {
    var speakers: [Speaker] = []
    var presentations: [Presentation] = []
    var events: [Event] = []
    var page: String
    var user: User
}

extension Request {    
    var user: User? {
        if let user = auth.get(User.self) {
            return user
        }
        return nil
    }
}
