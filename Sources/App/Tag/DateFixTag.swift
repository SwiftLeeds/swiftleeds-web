import Foundation
import Leaf
import Vapor

struct DateFixTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(identifier: "UTC")
        switch ctx.parameters.count {
        case 1: formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        case 2:
            guard let string = ctx.parameters[1].string else {
                throw "Unable to convert date format to string"
            }
            formatter.dateFormat = string

        default:
            throw "invalid parameters provided for date"
        }

        guard let dateAsDouble = ctx.parameters.first?.double else {
            throw "Unable to convert parameter to double for date"
        }
        let date = Date(timeIntervalSince1970: dateAsDouble)

        let dateAsString = formatter.string(from: date)
        return LeafData.string(dateAsString)
    }
}
