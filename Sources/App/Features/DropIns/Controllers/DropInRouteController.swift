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
        routes.get("slots", ":id", use: onRead)
        routes.post("slots", ":id", "update", use: onSlotUpdate)
    }
    
    @Sendable private func onRead(request: Request) async throws -> View {
        let session = try await request.parameters.get("id").map { id in
            DropInSession.query(on: request.db)
                .filter(\.$id == id)
                .with(\.$slots)
                .with(\.$event)
                .first()
        }?.get()
        
        let events = try await Event.query(on: request.db).sort(\.$date).all()
        let context = SessionContext(
            session: session,
            events: events,
            slots: session?.slots.sorted(by: { $0.date < $1.date }) ?? []
        )
        let layout = request.url.path.contains("slots") ? "dropin_slot_form" : "dropin_form"

        return try await request.view.render("Admin/Form/" + layout, context)
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
    
    @Sendable private func onSlotUpdate(request: Request) async throws -> Response {
        guard let id = request.parameters.get("id"), let uuid = UUID(uuidString: id) else {
            throw Abort(.badRequest, reason: "Failed to create UUID from provided value")
        }
        
        guard let session = try await DropInSession.query(on: request.db).filter(\.$id == uuid).with(\.$slots).first() else {
            throw Abort(.badRequest, reason: "Failed to find session")
        }
        
        let input = try request.content.decode(SlotFormInput.self)
        let slotValues: [(id: String, date: Date, duration: Int)] = try zip(zip(input.ids, input.time), input.duration)
            .map { tuple in
                guard let date = Self.formDateTimeFormatter().date(from: tuple.0.1) else {
                    throw Abort(.badRequest, reason: "Invalid Date Format Provided")
                }
                
                guard let duration = Int(tuple.1), duration > 0 else {
                    throw Abort(.badRequest, reason: "Invalid Duration Integer Provided")
                }
                
                return (tuple.0.0, date, duration)
            }
        
        if Set(slotValues.map { $0.date }).count != slotValues.count {
            throw Abort(.badRequest, reason: "Duplicate Slots at Same Time")
        }
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for slotTuple in slotValues {
                group.addTask {
                    // If a slot ID is provided, then query that. Otherwise, create a new slot.
                    guard let slot = slotTuple.id == "" ?
                        DropInSessionSlot() :
                                try await DropInSessionSlot.find(UUID(uuidString: slotTuple.id), on: request.db).get() else {
                        throw Abort(.badRequest, reason: "Failed to find existing slot")
                    }
                    
                    slot.$session.id = try session.requireID()
                    slot.date = slotTuple.date
                    slot.duration = slotTuple.duration
                    
                    if slotTuple.id == "" {
                        slot.id = .generateRandom()
                        try await slot.create(on: request.db)
                    } else {
                        try await slot.update(on: request.db)
                    }
                }
            }
            
            for slot in session.slots {
                if slotValues.contains(where: { $0.id == slot.id?.uuidString }) == false {
                    group.addTask {
                        try await slot.delete(on: request.db)
                    }
                }
            }
        }

        return Response(status: .ok, body: .init(string: "OK"))
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
        mutableSession.ownerLink = input.ownerLink
        
        if let imageUrl = try await uploadAndReturnImage(image.ownerImage) {
            mutableSession.ownerImageUrl = imageUrl
        }
        
        // Company
        if let companyName = input.companyName, let companyLink = input.companyLink {
            mutableSession.company = companyName
            mutableSession.companyLink = companyLink
            
            if let imageUrl = try await uploadAndReturnImage(image.companyImage) {
                mutableSession.companyImageUrl = imageUrl
            }
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
        let slots: [DropInSessionSlot]
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
    
    private struct SlotFormInput: Content {
        let ids: [String]
        let time: [String]
        let duration: [String]
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
        
        let slotModels: [DropInSessionSlotsContext.Slot] = session.slots.map {
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
