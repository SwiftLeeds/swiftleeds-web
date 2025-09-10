import Fluent
import Vapor

struct UserReviewControllerV2: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // GET /api/v2/reviews/{speakerId} - Get all reviews for a speaker
        routes.get(":speakerId", use: getReviews)
        
        // POST /api/v2/reviews/{speakerId} - Add a new review for a speaker
        routes.post(":speakerId", use: createReview)
    }
    
    @Sendable private func getReviews(request: Request) async throws -> Response {
        guard let speakerIdString = request.parameters.get("speakerId"),
              let speakerId = UUID(uuidString: speakerIdString) else {
            throw Abort(.badRequest, reason: "Invalid speaker ID")
        }
        
        // Get all events and determine current event (same pattern as Schedule API)
        let events = try await Event.query(on: request.db).all()
        guard let currentEvent = events.first(where: { $0.shouldBeReturned(by: request) }) else {
            throw UserReviewAPIError.eventNotFound
        }
        
        // Verify speaker exists and belongs to current event
        guard let speaker = try await Speaker.find(speakerId, on: request.db) else {
            throw Abort(.notFound, reason: "Speaker not found")
        }
        
        // Load speaker's presentations to verify they belong to current event
        try await speaker.$presentations.load(on: request.db)
        let speakerPresentations = try await speaker.$presentations.query(on: request.db)
            .with(\.$event)
            .all()
        
        // Verify speaker has presentations in the current event (same filtering as Schedule API)
        let hasCurrentEventPresentation = speakerPresentations.contains { presentation in
            presentation.event.id == currentEvent.id
        }
        
        guard hasCurrentEventPresentation else {
            throw Abort(.badRequest, reason: "Reviews are only available for current event speakers")
        }
        
        // Get all reviews for this speaker
        let reviews = try await UserReview.query(on: request.db)
            .filter(\.$speaker.$id == speakerId)
            .sort(\.$createdAt, .descending)
            .all()
        
        // Transform to response format
        let reviewResponses = reviews.compactMap(UserReviewTransformer.transform)
        
        return try await reviewResponses.encodeResponse(for: request)
    }
    
    @Sendable private func createReview(request: Request) async throws -> Response {
        guard let speakerIdString = request.parameters.get("speakerId"),
              let speakerId = UUID(uuidString: speakerIdString) else {
            throw Abort(.badRequest, reason: "Invalid speaker ID")
        }
        
        // Get all events and determine current event (same pattern as Schedule API)
        let events = try await Event.query(on: request.db).all()
        guard let currentEvent = events.first(where: { $0.shouldBeReturned(by: request) }) else {
            throw UserReviewAPIError.eventNotFound
        }
        
        // Verify speaker exists and belongs to current event
        guard let speaker = try await Speaker.find(speakerId, on: request.db) else {
            throw Abort(.notFound, reason: "Speaker not found")
        }
        
        // Load speaker's presentations to verify they belong to current event
        try await speaker.$presentations.load(on: request.db)
        let speakerPresentations = try await speaker.$presentations.query(on: request.db)
            .with(\.$event)
            .all()
        
        // Verify speaker has presentations in the current event (same filtering as Schedule API)
        let hasCurrentEventPresentation = speakerPresentations.contains { presentation in
            presentation.event.id == currentEvent.id
        }
        
        guard hasCurrentEventPresentation else {
            throw Abort(.badRequest, reason: "Reviews are only available for current event speakers")
        }
        
        // Validate and decode the input
        try UserReviewInput.validate(content: request)
        let input = try request.content.decode(UserReviewInput.self)
        
        // Create new review
        let review = UserReview(
            speakerId: speakerId,
            userName: input.userName,
            userInitials: input.userInitials,
            rating: input.rating,
            comment: input.comment
        )
        
        try await review.save(on: request.db)
        
        // Return the created review
        guard let createdReview = UserReviewTransformer.transform(review) else {
            throw Abort(.internalServerError, reason: "Failed to create review response")
        }
        
        return try await createdReview.encodeResponse(status: .created, for: request)
    }
}

extension UserReviewControllerV2 {
    enum UserReviewAPIError: Error {
        case eventNotFound
    }
}
