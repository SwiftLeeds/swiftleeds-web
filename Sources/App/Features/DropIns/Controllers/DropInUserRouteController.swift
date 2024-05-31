import Fluent
import Vapor

struct DropInUserRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ValidTicketMiddleware()).group("drop-in") { builder in
            // list available sessions
            builder.get { req async throws -> View in
                guard let currentEvent = req.storage.get(CurrentEventKey.self) else {
                    throw Abort(.badRequest, reason: "unable to identify current event")
                }
                
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
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
                    DropInSessionListContext(
                        sessions: viewModels,
                        hasValidTicket: ticket.release?.metadata?.canBookDropInSession == true
                    )
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
                        owners: $0.ticketOwner,
                        isOwner: $0.ticket.contains(ticket.slug)
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
                        slots: slotModelsGrouped,
                        prompt: req.query["prompt"]
                    )
                ).encodeResponse(for: req)
            }
            
            // return slot back to pool
            builder.get(":session", "cancel", ":slot") { req async throws -> Response in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let sessionID = try req.parameters.require("session")
                let slotID = try req.parameters.require("slot")
                
                guard let slotUUID = UUID(uuidString: slotID) else {
                    // slot ID not valid
                    return req.redirect(to: "/drop-in/\(sessionID)")
                }
                
                guard let slot = try await DropInSessionSlot.query(on: req.db).filter(\.$id == slotUUID).first() else {
                    // slot not found
                    return req.redirect(to: "/drop-in/\(sessionID)")
                }
                
                guard slot.ticket.contains(ticket.slug) else {
                    // it's not their ticket!
                    let message = "This is not your ticket to cancel."
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
                }
                
                // clear out ticket
                slot.ticket.removeAll(where: { $0 == ticket.slug })
                slot.ticketOwner.removeAll(where: { $0 == ticket.fullName })
                try await slot.save(on: req.db)
                
                let message = "Session cancelled, you may book another slot now."
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
            }
            
            // claim slot from pool
            builder.get(":session", "book", ":slot") { req async throws -> Response in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let sessionID = try req.parameters.require("session")
                let slotID = try req.parameters.require("slot")
                
                guard ticket.release?.metadata?.canBookDropInSession == true else {
                    // invalid ticket (likely a live stream pass) so can't book
                    let message = "Your ticket does not entitle you to a drop-in session."
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
                }
                
                guard let slotUUID = UUID(uuidString: slotID) else {
                    // slot ID not valid
                    return req.redirect(to: "/drop-in/\(sessionID)")
                }
                
                guard let slot = try await DropInSessionSlot.query(on: req.db).filter(\.$id == slotUUID).with(\.$session).first() else {
                    // slot not found
                    return req.redirect(to: "/drop-in/\(sessionID)")
                }
                
                if slot.ticket.count >= slot.session.maxTicketsPerSlot {
                    // ticket are all taken!
                    if slot.session.maxTicketsPerSlot == 1 {
                        let message = "This session has already been taken."
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
                    } else {
                        let message = "This session is already full."
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
                    }
                }
                
                let existingSlots: [DropInSessionSlot] = try await DropInSessionSlot
                    .query(on: req.db)
                    .with(\.$session)
                    .all()
                
                if existingSlots.filter({ $0.ticket.contains(ticket.slug) })
                                .contains(where: { $0.session.exclusivityKey == slot.session.exclusivityKey }) {
                    // they already have a slot booked with same exclusivity key
                    let message = "You already have a session of this type booked, please cancel it first before booking another."
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
                }
                
                // append ticket owner
                slot.ticket.append(ticket.slug)
                slot.ticketOwner.append(ticket.fullName)
                try await slot.save(on: req.db)
                
                let message = "Session booked, see you in Leeds!"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/drop-in/\(sessionID)?prompt=\(message ?? "")")
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
    let hasValidTicket: Bool
}

struct DropInSessionSlotsContext: Content {
    struct Slot: Codable {
        let id: String
        let date: Date
        let owners: [String]
        let isOwner: Bool
    }
    
    struct SlotGroup: Codable {
        let title: String
        let slots: [Slot]
    }
    
    let session: DropInSessionViewModel
    let slots: [SlotGroup]
    let prompt: String?
}
