import Foundation
import Leaf

struct NowTag: LeafTag {
    struct NowTagError: Error {}

    let formatter = DateFormatter()

    func render(_ ctx: LeafContext) throws -> LeafData {
        formatter.dateFormat = "yyyy-MM-dd"
        guard let string = ctx.parameters[0].double else {
            throw NowTagError()
        }

        let referenceDate = Date(timeIntervalSince1970: string)

        return LeafData.string(formatter.string(from: referenceDate))
    }
}
