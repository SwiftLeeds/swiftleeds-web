import Foundation

struct UserReviewTransformer {
    static func transform(_ userReview: UserReview) -> UserReviewResponse? {
        guard let id = userReview.id,
              let createdAt = userReview.createdAt else {
            return nil
        }
        
        // Format date to ISO 8601 format as required by the API
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: createdAt)
        
        return UserReviewResponse(
            id: id,
            userName: userReview.userName,
            userInitials: userReview.userInitials,
            rating: userReview.rating,
            comment: userReview.comment,
            date: dateString
        )
    }
}

