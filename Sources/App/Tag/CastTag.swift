import Foundation
import Leaf

struct CastTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        try ctx.requireParameterCount(2)
        
        let value = ctx.parameters[0] // value
        let type = ctx.parameters[1] // type
        
        return value.coerce(to: .init(rawValue: type.string ?? "string") ?? .string)
    }
}
