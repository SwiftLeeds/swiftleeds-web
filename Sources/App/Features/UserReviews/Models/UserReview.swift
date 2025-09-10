import Fluent
import Foundation
import Vapor

final class UserReview: Model, Content, @unchecked Sendable {
    static let schema = Schema.userReview

    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "speaker_id")
    var speaker: Speaker
    
    @Field(key: "user_name")
    var userName: String
    
    @Field(key: "user_initials")
    var userInitials: String
    
    @Field(key: "rating")
    var rating: Int // 1-5 stars
    
    @Field(key: "comment")
    var comment: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: IDValue? = nil, speakerId: UUID, userName: String, userInitials: String, rating: Int, comment: String?) {
        self.id = id
        self.$speaker.id = speakerId
        self.userName = userName
        self.userInitials = userInitials
        self.rating = rating
        self.comment = comment
    }
}

