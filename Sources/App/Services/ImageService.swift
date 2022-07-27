import Vapor
import S3

final class ImageService {

    @discardableResult
    static func uploadFile(data: Data, filename: String) async throws -> S3.PutObjectOutput {
        let putObjectRequest = S3.PutObjectRequest(
            acl: .publicRead,
            body: data,
            bucket: Environment.get("S3_BUCKET_NAME")!,
            contentLength: Int64(data.count),
            key: filename
        )
        
        let s3 = S3(
            accessKeyId: Environment.get("S3_KEY")!,
            secretAccessKey: Environment.get("S3_SECRET")!,
            region: .euwest2
        )
        
        return try await s3.putObject(putObjectRequest).get()
    }
}
