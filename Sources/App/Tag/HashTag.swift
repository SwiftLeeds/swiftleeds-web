import Foundation
import Leaf
import Vapor

// Not to be confused with #
struct HashTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let input = ctx.parameters[0].string else {
            throw Abort(.badRequest)
        }
        
        let normalised = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return LeafData.string(SHA256.hash(data: Data(normalised.utf8)).hexEncodedString())
    }
}
