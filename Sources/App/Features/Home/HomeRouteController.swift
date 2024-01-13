import Vapor

struct HomeRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped(User.sessionAuthenticator())
        route.get(use: get)
        route.get("schedule", use: schedule)
        route.get("cfp", use: cfp)
        route.get("team", use: team)
    }
    
    func get(req: Request) async throws -> View {
        let context = try await getContext(req: req)
        return try await req.view.render("Home/home", context)
    }
    
    func team(req: Request) async throws -> View {
        let context = TeamContext(teamMembers: [
            .init(
                name: "Adam Rush",
                role: "Founder and Host",
                twitter: "https://twitter.com/Adam9Rush",
                linkedin: "https://www.linkedin.com/in/swiftlyrush/",
                imageURL: "/img/team/rush.jpg"
            ),
            .init(
                name: "James Sherlock",
                role: "Visual and Technical Production",
                twitter: "https://twitter.com/JamesSherlouk",
                linkedin: "https://www.linkedin.com/in/jamessherlockdeveloper/",
                imageURL: "/img/team/sherlock.jpg"
            ),
            .init(
                name: "Matthew Gallagher",
                role: "Registration and Mobile App",
                twitter: "https://twitter.com/pdamonkey",
                linkedin: "https://www.linkedin.com/in/pdamonkey/",
                imageURL: "/img/team/matt.jpg"
            ),
            .init(
                name: "Adam Oxley",
                role: nil,
                twitter: "https://twitter.com/admoxly",
                linkedin: "https://www.linkedin.com/in/adam-oxley-41183a82/",
                imageURL: "/img/team/oxley.jpg"
            ),
            .init(
                name: "Noam Efergan",
                role: "Social Media",
                twitter: "https://twitter.com/No_Wham",
                linkedin: "https://www.linkedin.com/in/noamefergan/",
                imageURL: "/img/team/noam.jpg"
            ),
            .init(
                name: "Kannan Prasad",
                role: nil,
                twitter: nil,
                linkedin: "https://www.linkedin.com/in/kannanprasad/",
                imageURL: "/img/team/kannan.jpg"
            ),
            .init(
                name: "Muralidharan Kathiresan",
                role: nil,
                twitter: "https://twitter.com/Muralidharan_K",
                linkedin: "https://www.linkedin.com/in/muralidharankathiresan/",
                imageURL: "/img/team/mural.jpg"
            ),
            .init(
                name: "Preeti Thombare",
                role: nil,
                twitter: nil,
                linkedin: nil,
                imageURL: "/img/team/preeti.jpg"
            ),
            .init(
                name: "Paul Willis",
                role: nil,
                twitter: nil,
                linkedin: "https://www.linkedin.com/in/paulrobertwillis/",
                imageURL: "/img/team/paul.jpg"
            ),
            .init(
                name: "Joe Williams",
                role: "Camera Operator",
                twitter: "https://twitter.com/joedub_dev",
                linkedin: "https://www.linkedin.com/in/joe-williams-1676b871/",
                imageURL: "/img/team/joe.jpg"
            ),
        ].shuffled()) // Intentionally introduce randomness to remove bias. All volunteers are equals.
        
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
        
        let cfpContext = CfpContext(
            faqs: [
                .init(
                    question: "What topics can I talk about?",
                    answer: [
                        "It's a long list, but any talks surrounding the Swift language, the ecosystem (such as tooling, Swift Package Manager, Server-side Swift, or other non-Apple platforms), or any Apple operating system are all fair game. We also allow talks on design, architecture, working in software, indie development, testing, and more.",
                        "If in doubt, we would urge you to submit a proposal or discuss it with our team <a href=\"https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-wkmr6pif-ZDCdDeHM60jcBUy0BxHdCQ\" target=\"_blank\">on Slack</a>."
                    ]
                ),
                .init(
                    question: "I've not spoken before, can I apply?",
                    answer: [
                        "Absolutely. We welcome all speakers, whether it's their first time or their hundreth time. We provide optional speaker training for all successful applicants, and will work with you to answer any questions or concerns. We're here to help."
                    ]
                ),
                .init(
                    question: "Do I have to pay to talk at SwiftLeeds?",
                    answer: [
                        "You do not need to pay to talk at SwiftLeeds, in fact successful speakers will receive a ticket for both days at SwiftLeeds free of charge. We also pay for two days of accommodation, as well as breakfast and lunch at the venue on both days.",
                        "We will also support travel costs (flights or trains) up to £1,200 GBP or around $1,500 USD, where employers are unable to support."
                    ]
                ),
                .init(
                    question: "Are talks recorded or streamed?",
                    answer: [
                        "Yes! All talks at SwiftLeeds are recorded, and streamed live to remote attendees. Videos are uploaded to <a href=\"https://www.youtube.com/@swiftleeds\" target=\"_blank\">our YouTube channel</a> after the event.",
                        "We also photograph every talk too, which are made available on <a href=\"https://www.flickr.com/photos/196979204@N02/\" target=\"_blank\">our Flickr</a>."
                    ]
                ),
                .init(
                    question: "I'm dead, blind, or have other accessibility requirments. Can I apply?",
                    answer: [
                        "Absolutely. Let us know by emailing <a href=\"mailto:info@swiftleeds.co.uk\">info@swiftleeds.co.uk</a> and we'll work with you to ensure your needs are met throughout the process and at the venue. Contacting us with your needs will have no impact to the review of your talk proposal."
                    ]
                ),
                .init(
                    question: "How do you choose which speakers to have?",
                    answer: [
                        "In 2023 we had 149 talks submitted to our Call for Papers from over 100 speakers, and only 18 slots on the schedule. Choosing which talks to accept takes a lot of time, and is a huge challenge!",
                        "We utilise a tool called <a href=\"https://sessionize.com/\" target=\"_blank\">Sessionize</a> for evaluation of speakers. Our team of more than 10 volunteers each get randomly served three talks at a time and must rank them. At this stage we do not see who the speaker is, but only the title and description you provide.",
                        "This process is repeated 100s of times with many combinations of talks by each of our volunteers until a ranking is generated, at which point we find out who the speakers are.",
                        "With this ranking we work from the top and remove any duplicate talks, and additional talks from the same speaker. We'll then reach out to the top speakers to confirm their attendance, simply working down the list until we have the right number to fill our spots.",
                    ]
                )
            ],
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
        
        let phase = try getPhase(req: req)
        
        return HomeContext(
            speakers: phase.showSpeakers ? speakers : [],
            platinumSponsors: platinumSponsors,
            silverSponsors: silverSponsors,
            goldSponsors: goldSponsors,
            dropInSessions: phase.showDropIns ? dropInSessions : [],
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
    
    private func getPhase(req: Request) throws -> Phase {
        #if DEBUG
        let phaseQueryItem: String? = try? req.query.get(at: "phase")
        let phaseItems = phaseQueryItem?.components(separatedBy: ",") ?? []
        
        return Phase(
            showSpeakers: phaseItems.contains("speakers"),
            showSchedule: phaseItems.contains("schedule"),
            showDropIns: phaseItems.contains("dropin"),
            showTickets: phaseItems.contains("tickets")
        )
        #else
        Phase(
            showSpeakers: false,
            showSchedule: false,
            showDropIns: false,
            showTickets: false
        )
        #endif
    }
    
    private func getEvent(for req: Request) async throws -> Event? {
        #if DEBUG
        // Currently year-selector is only available on debug builds while we finish adding support
        if let yearQueryItem: String = try? req.query.get(at: "year") {
            return try await Event.query(on: req.db)
                .filter("name", .equal, "SwiftLeeds \(yearQueryItem)")
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
    let showDropIns: Bool
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
