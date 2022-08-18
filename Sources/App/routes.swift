import Vapor

let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22


func routes(_ app: Application) throws {
    
    // MARK: - Web Routes
    
    let route = app.routes.grouped(User.sessionAuthenticator())
 
    route.get { req -> View in
        do {
            let speakers = try await Speaker.query(on: req.db).with(\.$presentations).all()
            
            // There might be a better way to handle this, but Leaf templates don't
            // support dictionaries holding arrays,
            // e.g [.gold: [sponsor, sponsor], .platinum: [sponsor, sponsor]]
            let sponsorQuery = try await Sponsor.query(on: req.db).all()
            let platinumSponsors = sponsorQuery.filter { $0.sponsorLevel == .platinum }
            let silverSponsors = sponsorQuery.filter { $0.sponsorLevel == .silver }
            let goldSponsors = sponsorQuery.filter { $0.sponsorLevel == .gold }
            
            let slots = try await Slot.query(on: req.db)
                .with(\.$activity)
                .with(\.$presentation, { presentation in
                    presentation
                        .with(\.$speaker)
                        .with(\.$secondSpeaker)
                })
                .sort(\.$startDate)
                .all()


            slots.forEach { slot in
                print(slot.presentation?.speaker)
                print(slot.presentation?.secondSpeaker)
            }

            return try await req.view.render("Home/home", HomeContext(
                speakers: speakers,
                cfpEnabled: cfpExpirationDate > Date(),
                slots: slots,
                platinumSponsors: platinumSponsors,
                silverSponsors: silverSponsors,
                goldSponsors: goldSponsors
            ))
        } catch {
            return try await req.view.render("Home/home", HomeContext(cfpEnabled: cfpExpirationDate > Date()))
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
    try apiRoutes.grouped("activities").register(collection: ActivityAPIController())
    try apiRoutes.grouped("sponsors").register(collection: SponsorAPIController())
    try apiRoutes.grouped("schedule").register(collection: ScheduleAPIController())
    try apiRoutes.grouped("local").register(collection: LocalAPIController())

    let apiTwoRoutes = app.grouped("api", "v2")

    try apiTwoRoutes.grouped("schedule").register(collection: ScheduleAPIControllerV2())

    // MARK: - Admin Routes
    
    let adminRoutes = app.grouped("admin")
    
    adminRoutes.get("") { request -> View in
        guard let user = request.user, user.role == .admin else {
            return try await request.view.render("Home/home", HomeContext(speakers: [], cfpEnabled: cfpExpirationDate > Date(), slots: []))
        }
        
        let query = try? request.query.decode(PageQuery.self)
        let speakers = try await Speaker.query(on: request.db).with(\.$presentations).all()
        let presentations = try await Presentation.query(on: request.db)
            .with(\.$speaker)
            .with(\.$secondSpeaker)
            .all()
        let events = try await Event.query(on: request.db).all()
        let slots = try await Slot.query(on: request.db).with(\.$presentation).with(\.$activity).all()
        let activities = try await Activity.query(on: request.db).all()
        
        // There might be a better way to handle this, but Leaf templates don't
        // support dictionaries holding arrays,
        // e.g [.gold: [sponsor, sponsor], .platinum: [sponsor, sponsor]]
        let sponsorQuery = try await Sponsor.query(on: request.db).all()
        let platinumSponsors = sponsorQuery.filter { $0.sponsorLevel == .platinum }
        let silverSponsors = sponsorQuery.filter { $0.sponsorLevel == .silver }
        let goldSponsors = sponsorQuery.filter { $0.sponsorLevel == .gold }

        return try await request.view.render(
            "Admin/home",
            AdminContext(
                speakers: speakers,
                presentations: presentations,
                events: events,
                slots: slots,
                activities: activities,
                platinumSponsors: platinumSponsors,
                silverSponsors: silverSponsors,
                goldSponsors: goldSponsors,
                page: (query ?? PageQuery(page: "speakers")).page,
                user: user
            )
        )
    }
    
    try adminRoutes.grouped("presentations").register(collection: PresentationViewController())
    try adminRoutes.grouped("slots").register(collection: SlotViewController())
    try adminRoutes.grouped("activities").register(collection: ActivityViewController())
    try adminRoutes.grouped("sponsors").register(collection: SponsorViewController())
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
    var platinumSponsors: [Sponsor] = []
    var silverSponsors: [Sponsor] = []
    var goldSponsors: [Sponsor] = []
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
