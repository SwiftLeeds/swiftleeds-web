import Foundation
import Leaf

struct FirstTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        return ctx.parameters.first(where: { !$0.isNil }) ?? .trueNil
    }
}
