import Fluent
import Vapor

struct DropInRouteController: RouteCollection {
    struct DropinContext: Content {
        let sessions: [DropInSession]
    }
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("print", ":id", use: onPrint)
    }

    @Sendable private func onPrint(request: Request) async throws -> View {
        guard let sessionKey: String = request.parameters.get("id") else {
            throw Abort(.notFound)
        }
        
        guard let sessionKeyUUID = UUID(uuidString: sessionKey) else {
            throw Abort(.notFound)
        }
        
        let sessionOpt = try await DropInSession.query(on: request.db)
            .filter(\.$id == sessionKeyUUID)
            .with(\.$slots)
            .first()
        
        guard let session = sessionOpt else {
            throw Abort(.notFound)
        }
        
        let slotModels: [DropInSessionSlotsContext.Slot] = session.slots.compactMap {
            guard let id = $0.id?.uuidString else {
                return nil
            }
            
            return DropInSessionSlotsContext.Slot(
                id: id,
                date: $0.date,
                owners: $0.ticketOwner,
                isOwner: false
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
        
        let context = DropInSessionSlotsContext(session: .init(model: session), slots: slotModelsGrouped, prompt: nil)
        return try await request.view.render("Admin/dropins-print", context)
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
    let capacity: Int
    
    init(model: DropInSession) {
        self.id = model.id?.uuidString ?? ""
        self.title = model.title
        self.description = model.description
        self.owner = model.owner
        self.ownerImageUrl = model.ownerImageUrl
        self.ownerLink = model.ownerLink
        self.availability = Self.generateAvailabilityString(
            slotCount: model.slots.filter { $0.ticket.count < model.maxTicketsPerSlot }.count
        )
        self.capacity = model.maxTicketsPerSlot
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
