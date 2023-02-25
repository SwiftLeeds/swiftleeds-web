import Vapor

struct DropInRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.grouped(ValidTicketMiddleware()).group("drop-in") { builder in
            // list available sessions
            builder.get { req in
                guard let ticket = req.storage.get(TicketStorage.self) else {
                    throw Abort(.unauthorized, reason: "Ticket not present in session storage")
                }
                
                print(ticket)
                
                return "Show sessions. Ticket held by \(ticket.first_name)"
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
