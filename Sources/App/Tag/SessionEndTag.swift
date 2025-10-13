import Foundation
import Leaf

struct SessionEndTag: LeafTag {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = .init(identifier: "UTC")
        f.locale = .init(identifier: "en_US_POSIX")
        return f
    }()

    func render(_ ctx: LeafContext) throws -> LeafData {
        guard
            let startString = ctx.parameters[0].string, // e.g., "09:30"
            let duration = ctx.parameters[1].double, // duration in minutes
            let startDate = formatter.date(from: startString)
        else {
            return .string("")
        }

        let endDate = startDate.addingTimeInterval(duration * 60)
        return .string(formatter.string(from: endDate))
    }
}
