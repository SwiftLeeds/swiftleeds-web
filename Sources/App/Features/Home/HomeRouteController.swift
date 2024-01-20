import Vapor

struct HomeRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped(User.sessionAuthenticator())
        route.get(use: get)
        route.get("schedule", use: schedule)
        route.get("cfp", use: cfp)
        route.get("team", use: team)
        
        route.get("year", ":year", use: get)
        route.get("year", ":year", "schedule", use: schedule)
    }
    
    func get(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        return try await req.view.render("Home/home", context)
    }
    
    func team(req: Request) async throws -> View {
        guard let event = try await getEvent(for: req) else {
            throw Abort(.notFound, reason: "Unable to find event")
        }
        
        // We shuffle the team members array on each load request in order to remove any bias in the array.
        // All volunteers are shown equally.
        let context = TeamContext(
            teamMembers: teamMembers.shuffled(),
            event: event,
            eventDate: buildConferenceDateString(for: event),
            eventYear: event.name.components(separatedBy: " ").last
        )
        
        return try await req.view.render("Team/index", context)
    }
    
    func schedule(req: Request) async throws -> Response {
        let context = try await getContext(req: req)
        
        if context.phase?.showSchedule == false {
            // We already hide the link and CTA for the schedule, but users can manually go to this page prematurely
            // This makes sure they can't.
            return req.redirect(to: "/")
        }
        
        return try await req.view.render("Schedule/index", context).encodeResponse(for: req)
    }
    
    func cfp(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        let sessionize = try await SessionizeService().loadEvent(slug: "swiftleeds-ios-conference-in-leeds-c", req: req)
        
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
            event: context.event,
            eventDate: context.eventDate,
            eventYear: context.eventYear
        )
        
        return try await req.view.render("CFP/index", cfpContext)
    }
    
    func getContext(req: Request) async throws -> HomeContext {
        guard let event = try await getEvent(for: req) else {
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
        
        return HomeContext(
            speakers: phase.showSpeakers ? speakers : [],
            platinumSponsors: platinumSponsors,
            silverSponsors: silverSponsors,
            goldSponsors: goldSponsors,
            dropInSessions: dropInSessions,
            schedule: phase.showSchedule ? slots.schedule : [],
            phase: PhaseContext(phase: phase, event: event),
            event: event,
            eventDate: buildConferenceDateString(for: event),
            eventYear: event.name.components(separatedBy: " ").last
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
            .filter { $0.event.name == event.name }
    }
    
    private func getSlots(req: Request, event: Event) async throws -> [Slot] {
        try await Slot.query(on: req.db)
            .with(\.$activity)
            .with(\.$presentation) { presentation in
                presentation
                    .with(\.$speaker)
                    .with(\.$secondSpeaker)
            }
            .with(\.$event)
            .sort(\.$startDate)
            .all()
            .filter { $0.event.name == event.name }
    }
    
    private func getPhase(req: Request, event: Event) throws -> Phase {
        let isPreviousEvent = event.date <= Date() && event.date.timeIntervalSince1970 > 1420074000 // TODO: date should be nullable
        
        #if DEBUG
        let phaseQueryItem: String? = try? req.query.get(at: "phase")
        let phaseItems = phaseQueryItem?.components(separatedBy: ",") ?? []
        
        return Phase(
            showSpeakers: isPreviousEvent || phaseItems.contains("speakers"),
            showSchedule: isPreviousEvent || phaseItems.contains("schedule"),
            showTickets: true
        )
        #else
        // If the event is in the past then we can safely show schedule/speakers
        // TODO: if event is in the future, then rely on a database toggle
        return Phase(
            showSpeakers: isPreviousEvent,
            showSchedule: isPreviousEvent,
            showTickets: true // TODO: if event is current, and in the future, then check tito
        )
        #endif
    }
    
    private func getEvent(for req: Request) async throws -> Event? {
        #if DEBUG
        // Currently year-selector is only available on debug builds while we finish adding support
        if let yearParameterItem = req.parameters.get("year") {
            return try await Event.query(on: req.db)
                .filter("name", .equal, "SwiftLeeds \(yearParameterItem)")
                .first()
        }
        #endif
        
        return try await Event.getCurrent(on: req.db)
    }
    
    private func getNumberOfDays(for event: Event) -> Int {
        // TODO: move this logic into the database allowing a start and end date to be provided.
        
        guard let yearString = event.name.components(separatedBy: " ").last, let year = Int(yearString) else {
            return 1
        }
        
        // two days since 2023
        return year >= 2023 ? 2 : 1
    }
    
    func buildConferenceDateString(for event: Event) -> String? {
        let date = event.date
        
        // This is a slightly unintuitive capability which means if you set the date earlier than 2015 it will hide the date
        // This is for when we have yet to lock in the date.
        // TODO: make event.date optional in database
        guard date.timeIntervalSince1970 > 1420074000 else {
            return nil
        }
        
        let days = getNumberOfDays(for: event)
        
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        if days == 1 {
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date).uppercased()
        } else {
            // Month
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            
            // Day
            formatter.dateFormat = "d"
            let lowerDay = Int(formatter.string(from: date)) ?? 0
            let upperDay = lowerDay + (days - 1)
            
            return "\(lowerDay)-\(upperDay) \(month)".uppercased()
        }
    }
}

struct Phase {
    let showSpeakers: Bool
    let showSchedule: Bool
    let showTickets: Bool
}

struct PhaseContext: Codable {
    let ticketsEnabled: Bool
    let currentTicketPrice: String
    let showAddToCalendar: Bool
    let showSchedule: Bool
    let titoStub: String
    
    init(phase: Phase, event: Event) {
        ticketsEnabled = phase.showTickets
        titoStub = "swiftleeds-24" // TODO: load this from event in database
        currentTicketPrice = "£170" // TODO: need to load from tito
        showAddToCalendar = event.isCurrent && event.date.timeIntervalSince1970 > 1420074000 // TODO: make date optional in db and do nil check here
        showSchedule = phase.showSchedule
    }
}
