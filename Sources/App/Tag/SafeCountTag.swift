import Leaf
import Vapor

struct SafeCountTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        try ctx.requireParameterCount(1)
        if let array = ctx.parameters[0].array {
            return LeafData.int(array.count)
        } else if let dictionary = ctx.parameters[0].dictionary {
            return LeafData.int(dictionary.count)
        } else {
            // this is the 'safe' part - it'll just return 0 instead of an error
            return LeafData.int(0)
        }
    }
}
