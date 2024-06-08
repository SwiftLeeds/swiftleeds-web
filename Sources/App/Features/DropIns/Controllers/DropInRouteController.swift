import Fluent
import Vapor

struct DropInRouteController: RouteCollection {
    struct DropinContext: Content {
        let sessions: [DropInSession]
    }
    
    func boot(routes: RoutesBuilder) throws {
        // Modal
        routes.get(use: onRead)
        routes.get(":id", use: onRead)
        
        // Print Out
        routes.get("print", ":id", use: onPrint)
        
        // Form
        routes.post("create", use: onCreate)
        routes.post(":id", "delete", use: onDelete)
        routes.post(":id", "update", use: onUpdate)
        
        // Slots
    }
    
    @Sendable private func onRead(request: Request) async throws -> View {
        let session = try await request.parameters.get("id").map { id in
            DropInSession.query(on: request.db)
                .filter(\.$id == id)
                .with(\.$slots)
                .first()
        }?.get()
        
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = SessionContext(session: session, events: events)

        return try await request.view.render("Admin/Form/dropin_form", context)
    }
    
    @Sendable private func onDelete(request: Request) async throws -> Response {
        guard let session = try await request.parameters.get("id").map({ id in
            DropInSession.query(on: request.db)
                .filter(\.$id == id)
                .with(\.$slots)
                .first()
        })?.get() else { throw Abort(.notFound) }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            session.slots.forEach { slot in
                group.addTask {
                    try await slot.delete(on: request.db)
                }
            }
        }
        
        try await session.delete(on: request.db)
        return Response(status: .ok, body: .init(string: "OK"))
    }
    
    @Sendable private func onCreate(request: Request) async throws -> Response {
        return try await update(request: request, session: nil)
    }
    
    @Sendable private func onUpdate(request: Request) async throws -> Response {
        guard let session = try await DropInSession.find(request.parameters.get("id"), on: request.db) else {
            throw Abort(.badRequest, reason: "Failed to find session")
        }
        
        return try await update(request: request, session: session)
    }
    
    private func update(request: Request, session: DropInSession?) async throws -> Response {
        let input = try request.content.decode(FormInput.self)
        let image = try request.content.decode(ImageInput.self)
        
        let mutableSession = session ?? DropInSession()
        
        if session == nil {
            mutableSession.id = .generateRandom()
        }
        
        guard let event = try await Event.find(.init(uuidString: input.eventID), on: request.db) else {
            throw Abort(.badRequest, reason: "Failed to find event")
        }
        
        mutableSession.title = input.title
        mutableSession.description = input.description
        mutableSession.isPublic = input.isPublic == "on"
        mutableSession.$event.id = try event.requireID()
        
        mutableSession.maxTicketsPerSlot = {
            if input.isBookable != "on" {
                return 0
            }
            
            if input.isGroup == "on" {
                return input.groupSize ?? 0
            }
            
            // Is bookable, and isn't a group, so it's a 1:1
            return 1
        }()
        
        mutableSession.exclusivityKey = {
            // Handle manual overrides
            if let existingKey = session?.exclusivityKey, existingKey != "G", existingKey != "A" {
                return existingKey
            }
            
            if input.isGroup == "on" {
                return "G"
            }
            
            return "A"
        }()
        
        // Owner
        mutableSession.owner = input.ownerName
        mutableSession.ownerImageUrl = try await uploadAndReturnImage(image.ownerImage)
        mutableSession.ownerLink = input.ownerLink
        
        // Company
        if let companyName = input.companyName, let companyLink = input.companyLink {
            mutableSession.company = companyName
            mutableSession.companyImageUrl = try await uploadAndReturnImage(image.companyImage)
            mutableSession.companyLink = companyLink
        }
        
        // Update/Create
        if session == nil {
            try await mutableSession.create(on: request.db)
        } else {
            try await mutableSession.update(on: request.db)
        }
        
        return Response(status: .ok, body: .init(string: "OK"))
    }
    
    func uploadAndReturnImage(_ image: File?) async throws -> String? {
        guard let image = image, image.filename != "" else { return nil }
        
        let fileName = "\(UUID.generateRandom().uuidString)-\(image.filename)"
        try await ImageService.uploadFile(data: Data(image.data.readableBytesView), filename: fileName)
        return fileName
    }
    
    // MARK: - SessionContext
    private struct SessionContext: Content {
        let session: DropInSession?
        let events: [Event]
    }

    // MARK: - ImageInput
    private struct ImageInput: Content {
        let ownerImage: File?
        let companyImage: File?
    }

    // MARK: - FormInput
    private struct FormInput: Content {
        let title: String
        let description: String
        let ownerName: String
        let ownerLink: String
        let companyName: String?
        let companyLink: String?
        let isGroup: String?
        let groupSize: Int?
        let isPublic: String?
        let isBookable: String?
        let eventID: String
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
                date: $0.date,
                owners: $0.ticketOwner
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
        
        let context = DropInSessionSlotsContext(session: .init(model: session), slots: slotModelsGrouped)
        return try await request.view.render("Admin/dropins-print", context)
    }
}

struct DropInSessionViewModel: Codable {
    let id: String
    let title: String
    let description: String
    let owner: String
    
    init(model: DropInSession) {
        self.id = model.id?.uuidString ?? ""
        self.title = model.title
        self.description = model.description
        self.owner = model.owner
    }
}

struct DropInSessionSlotsContext: Content {
    struct Slot: Codable {
        let date: Date
        let owners: [String]
    }
    
    struct SlotGroup: Codable {
        let title: String
        let slots: [Slot]
    }
    
    let session: DropInSessionViewModel
    let slots: [SlotGroup]
}
