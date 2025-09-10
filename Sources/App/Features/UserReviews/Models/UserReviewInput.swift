import Foundation
import Vapor

struct UserReviewInput: Content {
    let userName: String
    let userInitials: String
    let rating: Int // 1-5 stars
    let comment: String?
}

extension UserReviewInput: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("userName", as: String.self, is: !.empty)
        validations.add("userInitials", as: String.self, is: !.empty && .count(1...3))
        validations.add("rating", as: Int.self, is: .range(1...5))
        validations.add("comment", as: String?.self, is: .nil || .count(...500))
    }
}

