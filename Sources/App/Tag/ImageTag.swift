import Leaf
import Vapor

struct AwsImageTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let bucketName = Environment.get("S3_BUCKET_NAME") else {
            throw Abort(.internalServerError, reason: "Missing 'S3_BUCKET_NAME' environment variable")
        }
        
        try ctx.requireParameterCount(1)
        
        guard let imagePath = ctx.parameters[0].string else {
            throw Abort(.badRequest, reason: "No image path was provided to image tag")
        }
        
        return .string("https://\(bucketName).s3.eu-west-2.amazonaws.com/\(imagePath)")
    }
}
