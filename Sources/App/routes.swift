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
    try app.routes.register(collection: PushController())
    try app.routes.register(collection: DropInRouteController())
    try app.routes.register(collection: TicketLoginController())
    
    // MARK: - API Routes
    
    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("sponsors").register(collection: SponsorAPIController())
    try apiRoutes.grouped("schedule").register(collection: ScheduleAPIControllerV2())
    try apiRoutes.grouped("local").register(collection: LocalAPIController())
    try apiRoutes.grouped("tickets").register(collection: TicketsAPIController())

    // MARK: - Admin Routes
    let adminRoutes = app.grouped("admin").grouped(AdminMiddleware())
    try adminRoutes.grouped("sponsors").register(collection: SponsorRouteController())
    try adminRoutes.grouped("speakers").register(collection: SpeakerRouteController())
    try adminRoutes.grouped("slots").register(collection: SlotRouteController())
    try adminRoutes.grouped("events").register(collection: EventRouteController())
    try adminRoutes.grouped("presentations").register(collection: PresentationRouteController())
    try adminRoutes.grouped("activities").register(collection: ActivityRouteController())
    try adminRoutes.grouped("jobs").register(collection: JobRouteController())

    adminRoutes.get { request -> View in
        let user = try request.auth.require(User.self)
        let query = try? request.query.decode(PageQuery.self)
        let speakers = try await Speaker.query(on: request.db).sort(\.$name).with(\.$presentations).all()
        let presentations = try await Presentation.query(on: request.db)
            .sort(\.$title)
            .with(\.$speaker)
            .with(\.$secondSpeaker)
            .all()
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let jobs = try await Job.query(on: request.db).sort(\.$title).all()
        let slots = try await Slot
            .query(on: request.db)
            .sort(\.$date)
            .sort(\.$startDate)
            .with(\.$presentation)
            .with(\.$activity)
            .all()
        let activities = try await Activity.query(on: request.db).sort(\.$title).all()

        guard let selectedEvent = try await Event
            .query(on: request.db)
            .all()
            .first(where: { $0.shouldBeReturned(by: request) })
        else {
            // better error or selection here
            throw ScheduleAPIController.ScheduleAPIError.notFound
        }
        
        // There might be a better way to handle this, but Leaf templates don't
        // support dictionaries holding arrays,
        // e.g [.gold: [sponsor, sponsor], .platinum: [sponsor, sponsor]]

        let sponsors = try await Sponsor.query(on: request.db).all()
        let platinumSponsors = sponsors.filter { $0.sponsorLevel == .platinum }
        let silverSponsors = sponsors.filter { $0.sponsorLevel == .silver }
        let goldSponsors = sponsors.filter { $0.sponsorLevel == .gold }

        return try await request.view.render(
            "Admin/home",
            AdminContext(
                activities: activities,
                events: events,
                jobs: jobs,
                presentations: presentations,
                slots: slots,
                speakers: speakers,
                sponsors: sponsors,
                platinumSponsors: platinumSponsors,
                silverSponsors: silverSponsors,
                goldSponsors: goldSponsors,
                selectedEvent: selectedEvent,
                page: (query ?? PageQuery(page: "speakers")).page,
                user: user
            )
        )
    }
}

struct PageQuery: Content {
    var page: String
}

struct AdminContext: Content {
    var activities: [Activity] = []
    var events: [Event] = []
    var jobs: [Job] = []
    var presentations: [Presentation] = []
    var slots: [Slot] = []
    var speakers: [Speaker] = []
    var sponsors: [Sponsor] = []
    var platinumSponsors: [Sponsor] = []
    var silverSponsors: [Sponsor] = []
    var goldSponsors: [Sponsor] = []
    var selectedEvent: Event
    var page: String
    var user: User
}

extension Request {
    var user: User? {
        return auth.get(User.self)
    }
}
