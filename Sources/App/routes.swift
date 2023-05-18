import Vapor

let cfpExpirationDate = Date(timeIntervalSince1970: 1682855940) // 30th April 23
let isDropInSessionsEnabled = true

func routes(_ app: Application) throws {
    // MARK: - Web Routes
    
    let route = app.routes.grouped(User.sessionAuthenticator())
 
    route.get { req -> View in
        do {
            let speakers = try await Speaker
                .query(on: req.db)
                .with(\.$presentations) {
                    $0.with(\.$event)
                }
                .all()
                .filter {
                    // filter speakers to only return those that have a presentation in the current event and where that
                    // presentation has been announced
                    $0.presentations.contains(where: { $0.event.isCurrent && $0.isTBA == false })
                }
            
            // There might be a better way to handle this, but Leaf templates don't
            // support dictionaries holding arrays,
            // e.g [.gold: [sponsor, sponsor], .platinum: [sponsor, sponsor]]
            let sponsorQuery = try await Sponsor.query(on: req.db)
                .with(\.$event)
                .all()
                .filter { $0.event.isCurrent }
            
            let platinumSponsors = sponsorQuery.filter { $0.sponsorLevel == .platinum }
            let silverSponsors = sponsorQuery.filter { $0.sponsorLevel == .silver }
            let goldSponsors = sponsorQuery.filter { $0.sponsorLevel == .gold }
            
            let dropInSessions = try await DropInSession.query(on: req.db)
                .with(\.$event)
                .all()
                .filter { $0.event.isCurrent }
            
            let slots = try await Slot.query(on: req.db)
                .with(\.$activity)
                .with(\.$presentation) { presentation in
                    presentation
                        .with(\.$speaker)
                        .with(\.$secondSpeaker)
                }
                .with(\.$event)
                .sort(\.$startDate)
                .all()
                .filter { $0.event.isCurrent }
            
            return try await req.view.render("Home/home", HomeContext(
                speakers: speakers,
                cfpEnabled: cfpExpirationDate > Date(),
                ticketsEnabled: true,
                slots: slots,
                platinumSponsors: platinumSponsors,
                silverSponsors: silverSponsors,
                goldSponsors: goldSponsors,
                dropInSessions: isDropInSessionsEnabled ? dropInSessions : []
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
    
    app.get("conduct") { req -> View in
        return try await req.view.render("Secondary/conduct", HomeContext())
    }

    try app.routes.register(collection: AuthController()) // TODO: Split this out into web/api/admin
    try app.routes.register(collection: SpeakerController()) // TODO: Split this out into web/api/admin
    try app.routes.register(collection: EventsController()) // TODO: Split this out into web/api/admin

    try app.routes.register(collection: PushController())
    
    try app.routes.register(collection: DropInRouteController())
    try app.routes.register(collection: TicketLoginController())
    
    // MARK: - API Routes
    
    let apiRoutes = app.grouped("api", "v1")
    
    try apiRoutes.grouped("presentations").register(collection: PresentationAPIController())
    try apiRoutes.grouped("slots").register(collection: SlotAPIController())
    try apiRoutes.grouped("activities").register(collection: ActivityAPIController())
    try apiRoutes.grouped("sponsors").register(collection: SponsorAPIController())
    try apiRoutes.grouped("schedule").register(collection: ScheduleAPIControllerV2())
    try apiRoutes.grouped("local").register(collection: LocalAPIController())
    try apiRoutes.grouped("tickets").register(collection: TicketsAPIController())

    // MARK: - Admin Routes
    
    let adminRoutes = app.grouped("admin").grouped(AdminMiddleware())
    
    adminRoutes.get { request -> View in
        let user = try request.auth.require(User.self)
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
        return auth.get(User.self)
    }
}
