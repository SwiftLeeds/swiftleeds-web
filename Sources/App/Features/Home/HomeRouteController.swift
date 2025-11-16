import Vapor

struct HomeRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let route = routes.grouped(User.sessionAuthenticator())
        route.get(use: get)
        route.get("schedule", use: schedule)
        route.get("cfp", use: cfp)
        route.get("team", use: team)
        
        route.get("year", ":year", use: get)
        route.get("year", ":year", "schedule", use: schedule)
    }
    
    @Sendable func get(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        
//        if req.application.conference == .kotlinleeds {
//            return try await req.view.render("Kotlin/home")
//        } else {
        return try await req.view.render("Home/home", context)
//        }
    }
    
    @Sendable func team(req: Request) async throws -> View {
        guard let event = try await getEvent(for: req) else {
            throw Abort(.notFound, reason: "Unable to find event")
        }
        
        try await event.$days.load(on: req.db)
        
        // Fetch team data from API to maintain consistency between web and mobile
        let teamAPIController = TeamAPIController()
        let teamResponse = try await teamAPIController.getTeam(req: req)
        
        // Convert API response to context format for the web template
        let teamMembers = teamResponse.teamMembers.map { member in
            TeamContext.TeamMember(
                name: member.name,
                role: member.role,
                twitter: member.twitter,
                linkedin: member.linkedin,
                slack: member.slack,
                imageURL: member.imageURL
            )
        }
        
        let context = TeamContext(
            teamMembers: teamMembers,
            event: EventContext(event: event)
        )
        
        return try await req.view.render("Team/index", context)
    }
    
    @Sendable func schedule(req: Request) async throws -> Response {
        let context = try await getContext(req: req)
        
        if context.phase?.showSchedule == false {
            // We already hide the link and CTA for the schedule, but users can manually go to this page prematurely
            // This makes sure they can't.
            return req.redirect(to: "/")
        }
        
        return try await req.view.render("Schedule/index", context).encodeResponse(for: req)
    }
    
    @Sendable func cfp(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        let sessionize = try await SessionizeService().loadEvent(slug: "swiftleeds-ios-conference-in-leeds", req: req)
        
        let stage = CfpContext.Stage(
            now: Date(),
            openDate: sessionize.cfpDates.startUtc,
            closeDate: sessionize.cfpDates.endUtc,
            reviewCompleted: context.speakers.isEmpty == false,
            cfpUrl: sessionize.cfpLink
        )
        
        let cfpContext = CfpContext(
            stage: stage,
            faqs: callForPaperFAQs,
            phase: context.phase,
            event: context.event
        )
        
        return try await req.view.render("CFP/index", cfpContext)
    }
    
    func getContext(req: Request) async throws -> HomeContext {
        guard let event = try await getEvent(for: req) else {
            throw Abort(.notFound, reason: "Unable to find event")
        }
        
        try await event.$days.load(on: req.db)
        
        let eventContext = EventContext(event: event)
        
        // Add some protection against unannounced years
        if eventContext.isHidden, req.user?.role != .admin {
            throw Abort(.notFound, reason: "Unable to find event")
        }
        
        let speakers = try await getSpeakers(req: req, event: event)
        let dropInSessions = try await getDropInSessions(req: req, event: event)
        let slots = try await getSlots(req: req, event: event)
        
        let sponsorQuery = try await getSponsors(req: req, event: event)
        let platinumSponsors = sponsorQuery.filter { $0.sponsorLevel == .platinum }
        let silverSponsors = sponsorQuery.filter { $0.sponsorLevel == .silver }
        let goldSponsors = sponsorQuery.filter { $0.sponsorLevel == .gold }
        
        let phase = try getPhase(req: req, event: event)
        
        let schedule = event.days
            .map { day in
                ScheduleDay(
                    name: day.name,
                    date: day.date,
                    slots: slots.filter { $0.day?.id == day.id }
                )
            }
            .filter {
                // Hide Empty Days
                !$0.slots.isEmpty
            }
            .sorted(by: {
                // Sort by Date (Chronological)
                $0.date < $1.date
            })
        
        let regularDropInSessions = dropInSessions.filter { $0.maxTicketsPerSlot == 1 }
        let groupDropInSessions = dropInSessions.filter { $0.maxTicketsPerSlot > 1 }

        return HomeContext(
            speakers: speakers,
            platinumSponsors: platinumSponsors,
            silverSponsors: silverSponsors,
            goldSponsors: goldSponsors,
            regularDropInSessions: regularDropInSessions,
            groupDropInSessions: groupDropInSessions,
            schedule: phase.showSchedule ? schedule : [],
            phase: PhaseContext(phase: phase, event: event),
            event: eventContext
        )
    }
    
    private func getSpeakers(req: Request, event: Event) async throws -> [Speaker] {
        try await Speaker
            .query(on: req.db)
            .with(\.$presentations) {
                $0.with(\.$event)
            }
            .all()
            .filter {
                // filter speakers to only return those that have a presentation in the current event and where that
                // presentation has been announced
                $0.presentations.contains(where: { $0.event.name == event.name && $0.isTBA == false })
            }
            .sorted(by: { $0.name < $1.name })
    }
    
    private func getSponsors(req: Request, event: Event) async throws -> [Sponsor] {
        try await Sponsor.query(on: req.db)
            .with(\.$event)
            .all()
            .filter { $0.event.name == event.name }
    }
    
    private func getDropInSessions(req: Request, event: Event) async throws -> [DropInSession] {
        try await DropInSession.query(on: req.db)
            .with(\.$event)
            .all()
            .filter { $0.event.name == event.name && $0.isPublic }
    }
    
    private func getSlots(req: Request, event: Event) async throws -> [Slot] {
        try await Slot.query(on: req.db)
            .with(\.$activity)
            .with(\.$presentation) { presentation in
                presentation
                    .with(\.$speaker)
                    .with(\.$secondSpeaker)
            }
            .with(\.$day) {
                $0.with(\.$event)
            }
            .sort(\.$startDate)
            .all()
            .filter { $0.day?.event.name == event.name }
    }
    
    private func getPhase(req _: Request, event: Event) throws -> Phase {
        // This is a little trick where we can set the date to anything older than 2015 to hide date and tickets
        let isHiddenEvent = event.date.timeIntervalSince1970 < 1420074000
        let isPreviousEvent = event.date <= Date()
        
        // TODO: If event is current, and in the future, then we should check Tito to ensure we're not sold out.
        return Phase(
            showSchedule: (isPreviousEvent && !isHiddenEvent) || event.showSchedule,
            showTickets: !isPreviousEvent && !isHiddenEvent
        )
    }
    
    private func getEvent(for req: Request) async throws -> Event? {
        if let yearParameterItem = req.parameters.get("year") {
            return try await Event.query(on: req.db)
                .filter("name", .custom("ilike"), "\(req.application.conference.rawValue) \(yearParameterItem)")
                .first()
        }
        
        return try await Event.getCurrent(req: req)
    }
}

struct Phase {
    let showSchedule: Bool
    let showTickets: Bool
}

struct PhaseContext: Codable {
    let ticketsEnabled: Bool
    let currentTicketPrice: String
    let showAddToCalendar: Bool
    let showSchedule: Bool
    let titoStub: String?
    
    init(phase: Phase, event: Event) {
        ticketsEnabled = phase.showTickets
        titoStub = event.titoEvent
        currentTicketPrice = "£180" // TODO: need to load from tito
        showAddToCalendar = event.isCurrent && event.date.timeIntervalSince1970 > 1420074000 // TODO: make date optional in db and do nil check here
        showSchedule = phase.showSchedule
    }
}
