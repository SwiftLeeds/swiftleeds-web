import Foundation
import Vapor

struct UserReviewResponse: Content {
    let id: UUID
    let userName: String
    let userInitials: String
    let rating: Int
    let comment: String?
    let date: String // ISO 8601 format
    let isCurrentUser: Bool = false // For now, always false since we don't have user authentication context
}

