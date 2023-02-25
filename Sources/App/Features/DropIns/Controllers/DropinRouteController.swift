import Fluent
import Vapor

struct DropInRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ValidTicketMiddleware()).group("drop-in") { builder in
            // list available sessions
            builder.get { req async throws -> View in
                guard let currentEvent = try await Event.query(on: req.db).filter(\.$isCurrent == true).first() else {
                    throw Abort(.badRequest, reason: "unable to identify current event")
                }
                
                let sessions = try await DropInSession.query(on: req.db)
                    .with(\.$event)
                    .filter(\.$event.$id == currentEvent.requireID())
                    .with(\.$slots)
                    .sort(.id)
                    .all()
                
                let viewModels = sessions.map {
                    DropInSessionViewModel(model: $0)
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
                
                let viewModel = DropInSessionViewModel(model: session)
                
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
    
    init(model: DropInSession) {
        self.id = model.id?.uuidString ?? ""
        self.title = model.title
        self.description = model.description
        self.owner = model.owner
        self.ownerImageUrl = model.ownerImageUrl
        self.ownerLink = model.ownerLink
        self.availability = Self.generateAvailabilityString(
            slotCount: model.slots.filter { $0.ticket == nil }.count
        )
    }
    
    static func generateAvailabilityString(slotCount: Int) -> String {
        switch slotCount {
        case 0:
            return "No slots available"
        case 1:
            return "1 slot available"
        default:
            return "\(slotCount) slots available"
        }
    }
}

struct DropInSessionListContext: Content {
    let sessions: [DropInSessionViewModel]
}

struct DropInSessionSlotsContext: Content {
    let session: DropInSessionViewModel
}
