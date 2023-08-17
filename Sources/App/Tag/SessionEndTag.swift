import Foundation
import Leaf

struct SessionEndTag: LeafTag {
    let formatter = DateFormatter()

    func render(_ ctx: LeafContext) throws -> LeafData {
        guard
            let startDate = ctx.parameters[0].double,
            let duration = ctx.parameters[1].double
        else { return .string("") }

        formatter.dateFormat = "HH:mm"

        let referenceDate = Date(timeIntervalSince1970: startDate)
        let endDate = referenceDate.addingTimeInterval(.init(Int(duration) * 60))

        return .string(formatter.string(from: endDate))
    }
}
