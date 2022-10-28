import S3
import Vapor

final class ImageService {
    @discardableResult
    static func uploadFile(data: Data, filename: String) async throws -> S3.PutObjectOutput {
        guard
            let bucketName = Environment.get("S3_BUCKET_NAME"),
            let accessKeyId = Environment.get("S3_KEY"),
            let secretAccessKey = Environment.get("S3_SECRET")
        else {
            throw Abort(.internalServerError, reason: "Missing either 'S3_BUCKET_NAME', 'S3_KEY' or 'S3_SECRET' environment variable(s)")
        }
        
        let putObjectRequest = S3.PutObjectRequest(
            acl: .publicRead,
            body: data,
            bucket: bucketName,
            contentLength: Int64(data.count),
            key: filename
        )
        
        let s3 = S3(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            region: .euwest2
        )
        
        return try await s3.putObject(putObjectRequest).get()
    }
}
