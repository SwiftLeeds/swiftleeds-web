import Fluent
import Vapor

struct TicketHubRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ValidTicketMiddleware()).group("ticket") { builder in
            builder.get { req -> View in
                // guard let currentEvent = try await Event.query(on: req.db).filter(\.$name == "SwiftLeeds 2023").first() else {
                guard let currentEvent = req.storage.get(CurrentEventKey.self) else {
                    throw Abort(.badRequest, reason: "unable to identify current event")
                }
                
                // Refund Period
                let refundDays: Int = Environment.get("REFUND_PERIOD").flatMap { Int($0) } ?? 30
                let refundDeadline = Date(timeIntervalSince1970: currentEvent.date.timeIntervalSince1970 - Double((60 * 60 * 24 * refundDays)))
                
                let formatter = DateFormatter()
                formatter.locale = .init(identifier: "en_US_POSIX")
                formatter.dateFormat = "d MMMM yyyy"
                
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let sessions = try await DropInSession.query(on: req.db)
                    .filter(\.$event.$id == currentEvent.requireID())
                    .with(\.$event) {
                        $0.with(\.$days)
                    }
                    .with(\.$slots)
                    .sort(.id)
                    .all()
                    .filter { $0.isPublic }
                
                let dropInSessions = sessions.filter { $0.maxTicketsPerSlot == 1 }.map { convertDropInSessionToViewModel($0, slug: ticket.slug) }
                let groupSessions = sessions.filter { $0.maxTicketsPerSlot > 1 }.map { convertDropInSessionToViewModel($0, slug: ticket.slug) }
                let userSessions = sessions.filter { $0.maxTicketsPerSlot > 0 && $0.slots.contains(where: { $0.ticket.contains(ticket.slug) }) }
                    .map { convertDropInSessionToViewModel($0, slug: ticket.slug) }
                
                let titoPrefill = #"{"email": "\#(ticket.email)", "name": "\#(ticket.fullName)"}"#
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                return try await req.view.render("Hub/home", TicketHubContext(
                    ticket: .init(
                        imageUrl: ticket.avatar_url?.absoluteString,
                        qrUrl: ticket.qr_url,
                        passbookUrl: "https://passbook.tito.io/tickets/\(ticket.slug)",
                        name: ticket.fullName,
                        email: ticket.email,
                        
                        // TODO: return nil here if the user has a talk show ticket
                        purchaseTalkshowUrl: "https://ti.to/swiftleeds/swiftleeds-24/with/live-talkshow?prefill=\(titoPrefill)"
                    ),
                    userSessions: userSessions,
                    dropInSessions: dropInSessions,
                    groupSessions: groupSessions,
                    refund: .init(
                        active: Date() < refundDeadline,
                        days: refundDays,
                        deadline: formatter.string(from: refundDeadline),
                        emailUrl: "mailto:info@swiftleeds.co.uk?subject=Refund Request&body=Ticket \(ticket.reference)"
                    ),
                    hasValidTicket: ticket.release?.metadata?.canBookDropInSession == true,
                    prompt: req.query["prompt"]
                ))
            }
            
            // return slot back to pool
            builder.get(":session", "cancel", ":slot") { req async throws -> Response in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let slotID = try req.parameters.require("slot")
                
                guard let slotUUID = UUID(uuidString: slotID) else {
                    // slot ID not valid
                    return req.redirect(to: "/ticket/")
                }
                
                guard let slot = try await DropInSessionSlot.query(on: req.db).filter(\.$id == slotUUID).first() else {
                    // slot not found
                    return req.redirect(to: "/ticket/")
                }
                
                guard slot.ticket.contains(ticket.slug) else {
                    // it's not their ticket!
                    let message = "This is not your ticket to cancel."
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
                }
                
                // clear out ticket
                slot.ticket.removeAll(where: { $0 == ticket.slug })
                slot.ticketOwner.removeAll(where: { $0 == ticket.fullName })
                try await slot.save(on: req.db)
                
                let message = "Session cancelled, you may book another slot now."
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
            }
            
            builder.get("logout") { req in
                req.session.destroy()
                return req.redirect(to: "/")
            }
            
            // claim slot from pool
            builder.get(":session", "book", ":slot") { req async throws -> Response in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                let slotID = try req.parameters.require("slot")
                
                guard ticket.release?.metadata?.canBookDropInSession == true else {
                    // invalid ticket (likely a live stream pass) so can't book
                    let message = "Your ticket does not entitle you to a drop-in session."
                        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
                }
                
                guard let slotUUID = UUID(uuidString: slotID) else {
                    // slot ID not valid
                    return req.redirect(to: "/ticket/")
                }
                
                guard let slot = try await DropInSessionSlot.query(on: req.db).filter(\.$id == slotUUID).with(\.$session).first() else {
                    // slot not found
                    return req.redirect(to: "/ticket/")
                }
                
                if slot.ticket.count >= slot.session.maxTicketsPerSlot {
                    // ticket are all taken!
                    if slot.session.maxTicketsPerSlot == 1 {
                        let message = "This session has already been taken."
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
                    } else {
                        let message = "This session is already full."
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        
                        return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
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
                    
                    return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
                }
                
                // append ticket owner
                slot.ticket.append(ticket.slug)
                slot.ticketOwner.append(ticket.fullName)
                try await slot.save(on: req.db)
                
                let message = "Session booked, see you in Leeds!"
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                return req.redirect(to: "/ticket/?prompt=\(message ?? "")")
            }
        }
    }
    
    func convertDropInSessionToViewModel(_ model: DropInSession, slug: String) -> TicketHubContext.Session {
        let slotsWithDay: [TicketHubContext.SessionSlot] = model.slots.grouped(by: { $0.date.dayNumberOfWeek() ?? -1 })
            .sorted(by: { $0.key < $1.key })
            .enumerated()
            .map { (offset, result) -> [TicketHubContext.SessionSlot] in
                result.value.map { slot in
                    let eventDay = model.event.days.first(where: { $0.date.withoutTime == slot.date.withoutTime })
                    
                    return TicketHubContext.SessionSlot(
                        id: slot.id?.uuidString ?? slot.date.description,
                        day: eventDay?.name ?? "Day \(offset + 1)",
                        date: slot.date,
                        duration: slot.duration,
                        isParticipant: slot.ticket.contains(slug),
                        isFullyBooked: slot.ticket.count == model.maxTicketsPerSlot,
                        participantCount: slot.ticket.count
                    )
                }
            }
            .flatMap { $0 }
            .sorted(by: {
                if $0.isParticipant {
                    // Always push slots the user is a participant of to the front (no matter what)
                    return true
                } else if !$0.isFullyBooked && $1.isFullyBooked {
                    // Push fully booked sessions to the front
                    return true
                } else if $0.isFullyBooked && !$1.isFullyBooked {
                    // Push fully booked sessions to the front
                    return false
                } else {
                    // Otherwise, sort by date
                    return $0.date < $1.date
                }
            })
        
        return TicketHubContext.Session(
            id: model.id?.uuidString ?? "#",
            title: model.title,
            description: model.description,
            ownerName: model.owner,
            ownerImageUrl: model.ownerImageUrl ?? "",
            ownerLink: model.ownerLink ?? "#",
            companyName: model.company,
            companyImageUrl: model.companyImageUrl,
            companyLink: model.companyLink,
            maximumAttendance: model.maxTicketsPerSlot,
            remainingSlots: slotsWithDay.map({ model.maxTicketsPerSlot - $0.participantCount }).reduce(0, +),
            slots: slotsWithDay
        )
    }
}

struct TicketHubContext: Content {
    struct Ticket: Codable {
        let imageUrl: String?
        let qrUrl: String?
        let passbookUrl: String
        let name: String
        let email: String
        let purchaseTalkshowUrl: String?
    }
    
    struct Refund: Codable {
        let active: Bool
        let days: Int
        let deadline: String
        let emailUrl: String
    }
    
    struct SessionSlot: Codable {
        let id: String
        let day: String
        let date: Date
        let duration: Int
        let isParticipant: Bool
        let isFullyBooked: Bool
        let participantCount: Int
    }
    
    struct Session: Codable {
        let id: String
        let title: String
        let description: String
        
        let ownerName: String
        let ownerImageUrl: String
        let ownerLink: String
        
        let companyName: String?
        let companyImageUrl: String?
        let companyLink: String?
        
        let maximumAttendance: Int
        let remainingSlots: Int
        
        let slots: [SessionSlot]
    }
    
    let ticket: Ticket
    let userSessions: [Session]
    let dropInSessions: [Session]
    let groupSessions: [Session]
    let refund: Refund
    let hasValidTicket: Bool
    let prompt: String?
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
