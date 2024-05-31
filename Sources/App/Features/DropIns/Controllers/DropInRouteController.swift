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
