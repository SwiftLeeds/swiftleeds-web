import Foundation
import Leaf

struct CopyrightTag: UnsafeUnescapedLeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        let copyrightText = "Copyright &copy;"
        let year: String

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"

        let currentYear = Int(formatter.string(from: .init())) ?? 0

        if let yearArgument = ctx.parameters[0].int, yearArgument != currentYear {
            year = "\(yearArgument) - \(currentYear)"
        } else {
            year = "\(currentYear)"
        }

        switch ctx.parameters.count {
        case 1:
            return .string("\(copyrightText) \(year)")
        case 2:
            let company = ctx.parameters[1].string ?? ""
            return .string("\(copyrightText) \(year) \(company)")
        default:
            return .string(copyrightText)
        }
    }
}
