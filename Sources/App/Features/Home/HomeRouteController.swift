import Vapor

struct HomeRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: get)
        routes.get("schedule", use: schedule)
    }
    
    func get(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        return try await req.view.render("Home/home", context)
    }
    
    func schedule(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        return try await req.view.render("Schedule/index", context)
    }
    
    func getContext(req: Request) async throws -> HomeContext {
        let event = try await Event.getCurrent(on: req.db)
        let speakers = try await getSpeakers(req: req)
        let dropInSessions = try await getDropInSessions(req: req)
        let slots = try await getSlots(req: req)
        let sponsorQuery = try await getSponsors(req: req)
        
        let platinumSponsors = sponsorQuery.filter { $0.sponsorLevel == .platinum }
        let silverSponsors = sponsorQuery.filter { $0.sponsorLevel == .silver }
        let goldSponsors = sponsorQuery.filter { $0.sponsorLevel == .gold }
        
        let phase = try getPhase(req: req)
        
        return HomeContext(
            speakers: phase.showSpeakers ? speakers : [],
            platinumSponsors: phase.showSponsors ? platinumSponsors : [],
            silverSponsors: phase.showSponsors ? silverSponsors : [],
            goldSponsors: phase.showSponsors ? goldSponsors : [],
            dropInSessions: phase.showDropIns ? dropInSessions : [],
            schedule: phase.showSchedule ? slots.schedule : [],
            phase: PhaseContext(phase: phase),
            event: event,
            eventDate: event.date.timeIntervalSince1970 > 1420074000 ? "9-10 OCT" : nil, // hide event date if older than 2015 (handle unknowns)
            eventYear: event.name.components(separatedBy: " ").last
        )
    }
    
    private func getSpeakers(req: Request) async throws -> [Speaker] {
        try await Speaker
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
            .sorted(by: { $0.name < $1.name })
    }
    
    private func getSponsors(req: Request) async throws -> [Sponsor] {
        try await Sponsor.query(on: req.db)
            .with(\.$event)
            .all()
            .filter { $0.event.isCurrent }
    }
    
    private func getDropInSessions(req: Request) async throws -> [DropInSession] {
        try await DropInSession.query(on: req.db)
            .with(\.$event)
            .all()
            .filter { $0.event.isCurrent }
    }
    
    private func getSlots(req: Request) async throws -> [Slot] {
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
            .filter { $0.event.isCurrent }
    }
    
    private func getPhase(req: Request) throws -> Phase {
        #if DEBUG
        let phaseQueryItem: String? = try? req.query.get(at: "phase")
        let phaseItems = phaseQueryItem?.components(separatedBy: ",") ?? []
        
        return Phase(
            showSponsors: phaseItems.contains("sponsors"),
            showSpeakers: phaseItems.contains("speakers"),
            showSchedule: phaseItems.contains("schedule"),
            showDropIns: phaseItems.contains("dropin"),
            showTickets: phaseItems.contains("tickets"),
            showCFP: phaseItems.contains("cfp")
        )
        #else
        Phase(
            showSponsors: true,
            showSpeakers: true,
            showSchedule: true,
            showDropIns: true,
            showTickets: true,
            showCFP: Date(timeIntervalSince1970: 1682855940) > Date() // 30th April 23
        )
        #endif
    }
}

struct Phase {
    let showSponsors: Bool
    let showSpeakers: Bool
    let showSchedule: Bool
    let showDropIns: Bool
    let showTickets: Bool
    let showCFP: Bool
}

struct PhaseContext: Codable {
    let ticketsEnabled: Bool
    let currentTicketPrice: String
    let cfpEnabled: Bool
    let showAddToCalendar: Bool
    let showSchedule: Bool
    let titoStub: String
    
    init(phase: Phase) {
        ticketsEnabled = phase.showTickets
        titoStub = "swiftleeds-24"
        currentTicketPrice = "£170" // TODO: need to load from tito
        cfpEnabled = phase.showCFP
        showAddToCalendar = false  // not implemented: https://add-to-calendar-button.com/
        showSchedule = phase.showSchedule
    }
}
