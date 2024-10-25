import Foundation
import Leaf

struct StaticLoopTag: UnsafeUnescapedLeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        let values = ctx.parameters[0].string?.components(separatedBy: " ") ?? []
        
        if values.isEmpty {
            return .trueNil
        }
        
        if case .raw(var value) = ctx.body?[0] {
            let string = value.readString(length: value.readableBytes) ?? ""
            return .string(values.map { string.replacingOccurrences(of: "[[VALUE]]", with: $0) }.joined())
        }
        
        return .trueNil
    }
}
