import Fluent
import Vapor

struct DropInRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // TODO: (James) load current event from DB
        let dbEventId = UUID(uuidString: "a6b202de-6135-4e71-bdb0-290ecff798a8")!
        
        routes.grouped(ValidTicketMiddleware()).group("drop-in") { builder in
            // list available sessions
            builder.get { req async throws -> View in
                let sessions = try await DropInSession.query(on: req.db)
                    .with(\.$event)
                    .filter(\.$event.$id == dbEventId)
                    .sort(.id)
                    .all()
                
                let viewModels = sessions.map {
                    DropInSessionViewModel(model: $0, availability: "TODO")
                }
                
                return try await req.leaf.render(
                    "Dropin/list",
                    DropInSessionListContext(sessions: viewModels)
                )
            }
            
            // list available slots for given session
            builder.get(":session") { req async throws -> Response in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let sessionKey: String = try req.parameters.require("session")
                
                guard let sessionKeyUUID = UUID(uuidString: sessionKey) else {
                    return try await req.redirect(to: "/drop-in").encodeResponse(for: req)
                }
                
                let sessionOpt = try await DropInSession.query(on: req.db)
                    .filter(\.$id == sessionKeyUUID)
                    .first()
                
                guard let session = sessionOpt else {
                    return try await req.redirect(to: "/drop-in").encodeResponse(for: req)
                }
                
                let viewModel = DropInSessionViewModel(model: session, availability: "")
                
                return try await req.leaf.render(
                    "Dropin/slots",
                    DropInSessionSlotsContext(session: viewModel)
                ).encodeResponse(for: req)
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

struct DropInSessionViewModel: Codable {
    let id: String
    let title: String
    let description: String
    let owner: String
    let ownerImageUrl: String?
    let ownerLink: String?
    let availability: String
    
    init(model: DropInSession, availability: String) {
        self.id = model.id?.uuidString ?? ""
        self.title = model.title
        print(model.description)
        self.description = model.description
        self.owner = model.owner
        self.ownerImageUrl = model.ownerImageUrl
        self.ownerLink = model.ownerLink
        self.availability = availability
    }
}

struct DropInSessionListContext: Content {
    let sessions: [DropInSessionViewModel]
}

struct DropInSessionSlotsContext: Content {
    let session: DropInSessionViewModel
}
