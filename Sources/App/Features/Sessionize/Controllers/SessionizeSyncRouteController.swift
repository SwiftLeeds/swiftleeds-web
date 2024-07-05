import Vapor

struct SessionizeSyncRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("modal", ":id", use: modal)
        routes.post("modal", ":id", "accept", use: commit)
    }
    
    @Sendable private func modal(request: Request) async throws -> View {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        
        guard let key = event.sessionizeKey else { throw Abort(.badRequest, reason: "No Sessionize Key for Event") }
        let sessionizeResponse = try await request.client.get("https://sessionize.com/api/v2/\(key)/view/All")
        let sessionize = try sessionizeResponse.content.decode(SessionizeResponse.self)
        let changes = try await identifyChanges(sessionize: sessionize, request: request, commit: [], event: event)
        
        let context = SyncContext(changes: changes, event: event)
        return try await request.view.render("Admin/sync_modal", context)
    }
    
    @Sendable private func commit(request: Request) async throws -> Response {
        guard let event = try await Event.find(request.parameters.get("id"), on: request.db) else { throw Abort(.notFound) }
        
        let input = try request.content.decode(FormInput.self)
        let commitIds = zip(input.ids, input.statuses).filter { $0.1 == "enabled" }.map { $0.0 }
        
        guard let key = event.sessionizeKey else { throw Abort(.badRequest, reason: "No Sessionize Key for Event") }
        let sessionizeResponse = try await request.client.get("https://sessionize.com/api/v2/\(key)/view/All")
        let sessionize = try sessionizeResponse.content.decode(SessionizeResponse.self)
        _ = try await identifyChanges(sessionize: sessionize, request: request, commit: commitIds, event: event)
        
        return Response(status: .ok, body: .init(string: "OK"))
    }
    
    private func identifyChanges(sessionize: SessionizeResponse, request: Request, commit: [String], event: Event) async throws -> [SyncContext.Change] {
        var changes = [SyncContext.Change]()
        
        for sessionizeSpeaker in sessionize.speakers {
            let id = UUID(uuidString: sessionizeSpeaker.id)!
            
            let speakerQuery = try await Speaker
                .query(on: request.db)
                .group(.or, { $0
                    .filter(\.$name, .equal, sessionizeSpeaker.fullName)
                    .filter(\.$id, .equal, UUID(uuidString: sessionizeSpeaker.id)!)
                })
                .first()
            
            let twitter = sessionizeSpeaker.links.first(where: { $0.linkType == "Twitter" })?.url
                .replacingOccurrences(of: "https://twitter.com/", with: "")
                .replacingOccurrences(of: "https://x.com/", with: "")
                .replacingOccurrences(of: "/", with: "")
            
            let linkedin = sessionizeSpeaker.links.first(where: { $0.linkType == "LinkedIn" })?.url
                .replacingOccurrences(of: "https://www.linkedin.com/", with: "")
                .replacingOccurrences(of: "https://linkedin.com/", with: "")
                .replacingOccurrences(of: "in/", with: "")
                .replacingOccurrences(of: "/", with: "")
            
            var website = sessionizeSpeaker.links.first(where: { $0.linkType == "Blog" })?.url ??
                sessionizeSpeaker.links.first(where: { $0.linkType == "Company_Website" })?.url
            
            var github: String? = nil
            
            if let websiteL = website, websiteL.contains("github.com") {
                github = websiteL.replacingOccurrences(of: "https://github.com/", with: "")
                website = nil
            }
            
            if let speaker = speakerQuery {
                var pairs = [SyncContext.Pair]()
                
                if speaker.name != sessionizeSpeaker.fullName {
                    pairs.append(.init(key: "Name", oldValue: speaker.name, newValue: sessionizeSpeaker.fullName))
                    speaker.name = sessionizeSpeaker.fullName
                }
                
                if speaker.biography != sessionizeSpeaker.bio {
                    pairs.append(.init(key: "Biography", oldValue: speaker.biography, newValue: sessionizeSpeaker.bio))
                    speaker.biography = sessionizeSpeaker.bio
                }
                
                if speaker.organisation != sessionizeSpeaker.tagLine {
                    pairs.append(.init(key: "Organisation", oldValue: speaker.organisation, newValue: sessionizeSpeaker.tagLine))
                    speaker.organisation = sessionizeSpeaker.tagLine
                }
                
                if speaker.twitter != twitter {
                    pairs.append(.init(key: "Twitter", oldValue: speaker.twitter ?? "-- Not Defined --", newValue: twitter ?? "-- Not Defined --"))
                    speaker.twitter = twitter
                }
                
                if speaker.linkedin != linkedin {
                    pairs.append(.init(key: "LinkedIn", oldValue: speaker.linkedin ?? "-- Not Defined --", newValue: linkedin ?? "-- Not Defined --"))
                    speaker.linkedin = linkedin
                }
                
                if speaker.website != website {
                    pairs.append(.init(key: "Website", oldValue: speaker.website ?? "-- Not Defined --", newValue: website ?? "-- Not Defined --"))
                    speaker.website = website
                }
                
                if speaker.github != github {
                    pairs.append(.init(key: "GitHub", oldValue: speaker.github ?? "-- Not Defined --", newValue: github ?? "-- Not Defined --"))
                    speaker.github = github
                }
                
                if pairs.isEmpty == false {
                    changes.append(.init(id: sessionizeSpeaker.id, modelType: .speaker, operationType: .update, pairs: pairs))
                }
                
                if commit.contains(sessionizeSpeaker.id) {
                    try await speaker.update(on: request.db)
                }
            } else {
                let newSpeaker = Speaker(
                    id: id,
                    name: sessionizeSpeaker.fullName,
                    biography: sessionizeSpeaker.bio,
                    profileImage: "",
                    organisation: sessionizeSpeaker.tagLine,
                    twitter: twitter
                )
                
                newSpeaker.linkedin = linkedin
                newSpeaker.website = website
                newSpeaker.github = github
                
                changes.append(.init(
                    id: sessionizeSpeaker.id,
                    modelType: .speaker,
                    operationType: .create,
                    pairs: [
                        .init(key: "Name", oldValue: nil, newValue: sessionizeSpeaker.fullName),
                        .init(key: "Biography", oldValue: nil, newValue: sessionizeSpeaker.bio),
                        .init(key: "Organisation", oldValue: nil, newValue: sessionizeSpeaker.tagLine),
                        .init(key: "Twitter", oldValue: nil, newValue: newSpeaker.twitter ?? "-- Not Defined --"),
                        .init(key: "LinkedIn", oldValue: nil, newValue: newSpeaker.linkedin ?? "-- Not Defined --"),
                        .init(key: "Website", oldValue: nil, newValue: newSpeaker.website ?? "-- Not Defined --"),
                        .init(key: "GitHub", oldValue: nil, newValue: newSpeaker.github ?? "-- Not Defined --"),
                    ]
                ))
                
                if commit.contains(sessionizeSpeaker.id) {
                    guard let data = try await request.client.get(URI(string: sessionizeSpeaker.profilePicture.absoluteString)).body else {
                        throw Abort(.badRequest, reason: "failed to download image")
                    }
                    
                    let fileName = sessionizeSpeaker.profilePicture.absoluteString.components(separatedBy: "/").last!
                    try await ImageService.uploadFile(data: Data(buffer: data), filename: fileName)
                    newSpeaker.profileImage = fileName
                    
                    try await newSpeaker.create(on: request.db)
                }
            }
        }
        
        for sessionizeSession in sessionize.sessions {
            let sessionQuery = try await Presentation
                .query(on: request.db)
                .filter(\.$title, .equal, sessionizeSession.title)
                .first()
            
            if let session = sessionQuery {
                var pairs = [SyncContext.Pair]()
                
                if session.synopsis != sessionizeSession.description {
                    pairs.append(.init(key: "Description", oldValue: session.synopsis, newValue: sessionizeSession.description))
                    session.synopsis = sessionizeSession.description
                }
                
                if pairs.isEmpty == false {
                    changes.append(.init(id: sessionizeSession.id, modelType: .presentation, operationType: .update, pairs: pairs))
                }
                
                if commit.contains(sessionizeSession.id) {
                    try await session.update(on: request.db)
                }
            } else {
                let newSession = Presentation(
                    id: .generateRandom(),
                    title: sessionizeSession.title,
                    synopsis: sessionizeSession.description,
                    isTBA: true,
                    slidoURL: nil,
                    videoURL: nil
                )
                
                let speakers = sessionize.speakers
                    .filter { sessionizeSession.speakers.contains($0.id) }
                    .map { $0.fullName }
                
                changes.append(.init(
                    id: sessionizeSession.id,
                    modelType: .presentation,
                    operationType: .create,
                    pairs: [
                        .init(key: "Title", oldValue: nil, newValue: sessionizeSession.title),
                        .init(key: "Description", oldValue: nil, newValue: sessionizeSession.description),
                        .init(key: "Speakers", oldValue: nil, newValue: speakers.joined(separator: " and "))
                    ]
                ))
                
                if commit.contains(sessionizeSession.id) {
                    newSession.$event.id = try event.requireID()
                    
                    var modelSpeakers: [Speaker] = []
                    
                    for speaker in speakers {
                        guard let speaker = try await Speaker.query(on: request.db).filter(\.$name, .equal, speaker).first() else {
                            throw Abort(.badRequest, reason: "Failed to find speaker")
                        }
                        
                        modelSpeakers.append(speaker)
                    }
                    
                    if modelSpeakers.count >= 1 {
                        newSession.$speaker.id = try modelSpeakers[0].requireID()
                    }
                    
                    if modelSpeakers.count == 2 {
                        newSession.$secondSpeaker.id = try modelSpeakers[1].requireID()
                    }
                    
                    try await newSession.create(on: request.db)
                }
            }
        }
        
        return changes
    }
    
    private struct FormInput: Content {
        let ids: [String]
        let statuses: [String]
    }
    
    struct SyncContext: Content {
        enum ModelType: String, Codable {
            case speaker, presentation
        }
        
        enum OperationType: String, Codable {
            case create, update
        }
        
        struct Pair: Codable {
            let key: String
            let oldValue: String?
            let newValue: String
        }
        
        struct Change: Codable {
            let id: String
            let modelType: ModelType
            let operationType: OperationType
            let pairs: [Pair]
        }
        
        let changes: [Change]
        let event: Event
    }
    
    struct SessionizeResponse: Decodable {
        struct Link: Decodable {
            let linkType: String
            let url: String
        }
        
        struct Speaker: Decodable {
            let id: String
            let fullName: String
            let bio: String
            let tagLine: String
            let links: [Link]
            let profilePicture: URL
        }
        
        struct Session: Decodable {
            let id: String
            let title: String
            let description: String
            let speakers: [String]
        }
        
        let sessions: [Session]
        let speakers: [Speaker]
    }
}
