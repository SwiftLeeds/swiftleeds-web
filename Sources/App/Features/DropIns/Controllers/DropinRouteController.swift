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
                    .with(\.$slots)
                    .first()
                
                guard let session = sessionOpt else {
                    return try await req.redirect(to: "/drop-in").encodeResponse(for: req)
                }
                
                let slotModels: [DropInSessionSlotsContext.Slot] = session.slots.compactMap {
                    guard let id = $0.id?.uuidString else {
                        return nil
                    }
                    
                    return DropInSessionSlotsContext.Slot(
                        id: id,
                        date: $0.date,
                        owner: $0.ticketOwner,
                        isOwner: $0.ticket == ticket.slug
                    )
                }.sorted(by: { $0.date < $1.date }) // sort times so they're in order on the day
                
                // group by the day of the week (Wednesday, Thursday, etc)
                let slotModelsGrouped = Dictionary(grouping: slotModels) { slot in slot.date.dayNumberOfWeek() ?? -1 }
                    // order (Wednesday before Thursday)
                    .sorted(by: { $0.key < $1.key })
                    // enumerate them to turn into conference day number
                    .enumerated()
                    .map { (offset, result) in
                        DropInSessionSlotsContext.SlotGroup(title: "Day \(offset + 1)", slots: result.value)
                    }
                
                return try await req.leaf.render(
                    "Dropin/slots",
                    DropInSessionSlotsContext(
                        session: DropInSessionViewModel(model: session),
                        slots: slotModelsGrouped
                    )
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

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
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
    struct Slot: Codable {
        let id: String
        let date: Date
        let owner: String?
        let isOwner: Bool
    }
    
    struct SlotGroup: Codable {
        let title: String
        let slots: [Slot]
    }
    
    let session: DropInSessionViewModel
    let slots: [SlotGroup]
}
