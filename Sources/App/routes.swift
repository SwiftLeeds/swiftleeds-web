import Vapor

func routes(_ app: Application) throws {
    // MARK: - Web Routes

    try app.routes.register(collection: HomeRouteController())
    
    #if DEBUG
    try app.routes.register(collection: TalkRouteController())
    #endif
    
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
    
    app.get("robots.txt") { _ -> String in
        let disallowedPaths = [
            "/purchase", // Not intended for direct access, only redirect from tito
            "/admin", // Not intended for normal users
            "/api/", // Not intended for SEO
            "/login", // Not intended for normal users (only used for admin)
        ]
        .map { "Disallow: " + $0 }
        .joined(separator: "\n")
        
        return """
        User-agent: *
        \(disallowedPaths)
        """
    }

    try app.routes.register(collection: AuthController()) // TODO: Split this out into web/api/admin
    try app.routes.register(collection: PushController())
    try app.routes.register(collection: TicketLoginController())
    try app.routes.register(collection: TicketHubRouteController())
    try app.routes.register(collection: PurchaseRouteController())
    
    // MARK: - API Routes
    
    let apiRoutes = app.grouped("api", "v1")
    try apiRoutes.grouped("sponsors").register(collection: SponsorAPIController())
    try apiRoutes.grouped("schedule").register(collection: ScheduleAPIController())
    try apiRoutes.grouped("local").register(collection: LocalAPIController())
    try apiRoutes.grouped("tickets").register(collection: TicketsAPIController())
    try apiRoutes.grouped("checkin").register(collection: CheckInAPIController())
    
    let apiV2Routes = app.grouped("api", "v2")
    try apiV2Routes.grouped("schedule").register(collection: ScheduleAPIControllerV2())
    try apiV2Routes.grouped("team").register(collection: TeamAPIController())

    // MARK: - Admin Routes

    let adminRoutes = app.grouped("admin").grouped(AdminMiddleware())
    try adminRoutes.grouped("sponsors").register(collection: SponsorRouteController())
    try adminRoutes.grouped("speakers").register(collection: SpeakerRouteController())
    try adminRoutes.grouped("slots").register(collection: SlotRouteController())
    try adminRoutes.grouped("events").register(collection: EventRouteController())
    try adminRoutes.grouped("presentations").register(collection: PresentationRouteController())
    try adminRoutes.grouped("activities").register(collection: ActivityRouteController())
    try adminRoutes.grouped("jobs").register(collection: JobRouteController())
    try adminRoutes.grouped("dropins").register(collection: DropInRouteController())
    try adminRoutes.grouped("sessionize").register(collection: SessionizeSyncRouteController())
    try adminRoutes.grouped("days").register(collection: EventDayRouteController())

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
        let jobs = try await Job.query(on: request.db).sort(\.$title)
            .with(\.$sponsor)
            .all()
        let slots = try await Slot
            .query(on: request.db)
            .sort(\.$startDate)
            .with(\.$day)
            .with(\.$presentation)
            .with(\.$activity)
            .all()
            .sorted {
                guard let d1 = $0.day?.date, let d2 = $1.day?.date else {
                    return false
                }
                return d1 < d2
            }
        let activities = try await Activity
            .query(on: request.db)
            .sort(\.$event.$id, .descending) // This moves 'Reusable' events to the top of the filtered view
            .sort(\.$title)
            .all()
        let days = try await EventDay.query(on: request.db).all()
            .sorted(by: { $0.date < $1.date })

        let selectedEvent = events.first(where: { $0.shouldBeReturned(by: request) }) ?? events.first(where: { $0.isCurrent }) ?? events[0]
        
        // There might be a better way to handle this, but Leaf templates don't
        // support dictionaries holding arrays,
        // e.g [.gold: [sponsor, sponsor], .platinum: [sponsor, sponsor]]

        let sponsors = try await Sponsor.query(on: request.db).all()
        let platinumSponsors = sponsors.filter { $0.sponsorLevel == .platinum }
        let silverSponsors = sponsors.filter { $0.sponsorLevel == .silver }
        let goldSponsors = sponsors.filter { $0.sponsorLevel == .gold }
        
        let dropInSessions = try await DropInSession.query(on: request.db)
            .with(\.$event)
            .with(\.$slots)
            .all()

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
                dropInSessions: dropInSessions,
                selectedEvent: selectedEvent,
                page: (query ?? PageQuery(page: "speakers")).page,
                days: days,
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
    var dropInSessions: [DropInSession] = []
    var selectedEvent: Event
    var page: String
    var days: [EventDay] = []
    var user: User
}

extension Request {
    var user: User? {
        return auth.get(User.self)
    }
}
