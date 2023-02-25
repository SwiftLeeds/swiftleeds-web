import Vapor

struct DropInRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ValidTicketMiddleware()).group("drop-in") { builder in
            // list available sessions
            builder.get { req async throws -> View in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                return try await req.leaf.render(
                    "Dropin/List",
                    DropInSessionListContext(sessions: DropInSession.sessions)
                )
            }
            
            // list available slots for given session
            builder.get(":session") { req in
                // let session = try req.parameters.require("session")
                return "session"
            }
            
            // return slot back to pool
            builder.delete(":session") { req in
                // let session = try req.parameters.require("session")
                return "deleted"
            }
            
            // claim slot from pool
            builder.put(":session") { req in
                // let session = try req.parameters.require("session")
                return "inserted"
            }
        }
    }
}

struct DropInSession: Codable {
    let id: String
    let title: String
    let description: String
    let owner: String
    let ownerImageUrl: String
    let ownerLink: String
    let availability: String
}

struct DropInSessionListContext: Content {
    let sessions: [DropInSession]
}

extension DropInSession {
    static var sessions: [DropInSession] = [
        .init(
            id: "1",
            title: "App Design Review",
            description: """
            We are excited to have Hidde van der Ploeg available to provide a design review of your iOS application.

            You will be allocated a timeslot throughout the day of the conference, and you can sit down, ask questions and get the opinion of a design expert.
            """,
            owner: "Hidde van der Ploeg",
            ownerImageUrl: "https://pbs.twimg.com/profile_images/1597353545904316417/Zpow22F5_400x400.jpg",
            ownerLink: "https://twitter.com/hiddevdploeg",
            availability: "No slots available"
        ),
        
        .init(
            id: "2",
            title: "App Store Optimization Review",
            description: """
            We are excited to have Ariel from AppFigures available to provide a full App Store Optimization review of your app.

            You will be allocated a timeslot throughout the day of the conference, and you can sit down, ask questions and get the opinion of an ASO expert.
            """,
            owner: "Ariel from Appfigures",
            ownerImageUrl: "https://pbs.twimg.com/profile_images/1609004676774592513/y4oh0Nb__400x400.jpg",
            ownerLink: "https://twitter.com/arielmichaeli",
            availability: "16 slots available"
        ),
    
        .init(
            id: "3",
            title: "Indie Developer App Review",
            description: """
            Do you have an Indie App you would like to get **FREE** advice about?

            Jordi Bruin will be onsite, ready to answer your questions about your app and help you with anything that you might be struggling with, code or otherwise.

            Jordi Bruin is a world-class Indie app developer and was recently nominated for an Apple Design Award. Slots will be limited and on a first-come, first-serve basis. By opting for this in your ticket, you'll be provided with a set day and time for meeting Jordi Bruin in a 1-1 meeting.

            **Please note;** you must only opt for this if your app is built by you independently and isn't a company application.
            """,
            owner: "Jordi Bruin",
            ownerImageUrl: "https://pbs.twimg.com/profile_images/1302138759677345792/Tp9T2p2C_400x400.jpg",
            ownerLink: "https://twitter.com/jordibruin",
            availability: "1 slot available"
        ),
    
        .init(
            id: "4",
            title: "App Accessibility Review",
            description: """
            todo
            """,
            owner: "Daniel Devesa Derksen-Staats",
            ownerImageUrl: "https://pbs.twimg.com/profile_images/472077462596096001/O87Gvgjg_400x400.jpeg",
            ownerLink: "https://twitter.com/dadederk",
            availability: "31 slots available"
        )
    ]
}
