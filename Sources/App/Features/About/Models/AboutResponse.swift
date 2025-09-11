import Foundation
import Vapor

struct AboutResponse: Content {
    let title: String
    let description: [String]
    let foundedYear: String
    let founderName: String
    let founderTwitter: String
}
