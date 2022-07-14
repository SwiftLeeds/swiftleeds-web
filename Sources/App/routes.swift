import Vapor

let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22


func routes(_ app: Application) throws {
    
    // MARK: - Web Routes
    
    let route = app.routes.grouped(User.sessionAuthenticator())
 
    route.get { req -> View in
        do {
            let speakers = try await Speaker.query(on: req.db).with(\.$presentations).all()
            if let slots = try? await Slot.query(on: req.db)
                .with(\.$activity)
                .with(\.$presentation, { presentation in
                    presentation.with(\.$speaker)
                })
                .sort(\.$startDate)
                .all() {
                return try await req.view.render("Home/home", HomeContext(speakers: speakers, cfpEnabled: cfpExpirationDate > Date(), slots: slots))
            }
            return try await req.view.render("Home/home", HomeContext(speakers: speakers, cfpEnabled: cfpExpirationDate > Date(), slots: []))
        } catch {
            return try await req.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), slots: []))
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
    
    app.get("conduct") { req -> EventLoopFuture<View> in
        return req.view.render("Secondary/conduct", ["name": "Leaf"])
    }

    try app.routes.register(collection: AuthController()) // TODO: Split this out into web/api/admin
    try app.routes.register(collection: SpeakerController()) // TODO: Split this out into web/api/admin
    try app.routes.register(collection: EventsController()) // TODO: Split this out into web/api/admin
    
    // MARK: - API Routes
    
    let apiRoutes = app.grouped("api", "v1")
    
    try apiRoutes.grouped("presentations").register(collection: PresentationAPIController())
    try apiRoutes.grouped("slots").register(collection: SlotAPIController())

    // MARK: - Admin Routes
    
    let adminRoutes = app.grouped("admin")
    
    adminRoutes.get("") { request -> View in
        guard let user = request.user, user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), slots: []))
        }
        let query = try? request.query.decode(PageQuery.self)
        let speakers = try await Speaker.query(on: request.db).with(\.$presentations).all()
        let presentations = try await Presentation.query(on: request.db).with(\.$speaker).all()
        let events = try await Event.query(on: request.db).all()
        let slots = try await Slot.query(on: request.db).with(\.$presentation).with(\.$activity).all()
        let activities = try await Activity.query(on: request.db).all()
        return try await request.view.render(
            "Admin/home",
            AdminContext(
                speakers: speakers,
                presentations: presentations,
                events: events,
                slots: slots,
                activities: activities,
                page: (query ?? PageQuery(page: "speakers")).page,
                user: user
            )
        )
    }
    
    try adminRoutes.grouped("presentations").register(collection: PresentationViewController())
    try adminRoutes.grouped("slots").register(collection: SlotViewController())
}

struct PageQuery: Content {
    var page: String
}

struct AdminContext: Content {
    var speakers: [Speaker] = []
    var presentations: [Presentation] = []
    var events: [Event] = []
    var slots: [Slot] = []
    var activities: [Activity] = []
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
