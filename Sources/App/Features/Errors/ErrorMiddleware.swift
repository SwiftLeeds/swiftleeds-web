import Vapor

public final class ErrorFileMiddleware: AsyncMiddleware {
    struct ErrorResponse: Codable {
        let error: Bool
        let reason: String
        let code: String
    }
    
    public func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: req)
        } catch {
            let status: HTTPResponseStatus
            let reason: String
            let source: ErrorSource
            var headers: HTTPHeaders

            // Inspect the error type and extract what data we can.
            switch error {
            case let debugAbort as (any DebuggableError & AbortError):
                (reason, status, headers, source) = (debugAbort.reason, debugAbort.status, debugAbort.headers, debugAbort.source ?? .capture())
                
            case let abort as any AbortError:
                (reason, status, headers, source) = (abort.reason, abort.status, abort.headers, .capture())
            
            case let debugErr as any DebuggableError:
                (reason, status, headers, source) = (debugErr.reason, .internalServerError, [:], debugErr.source ?? .capture())
            
            default:
                // In debug mode, provide the error description; otherwise hide it to avoid sensitive data disclosure.
                reason = req.application.environment.isRelease ? "Something went wrong." : String(describing: error)
                (status, headers, source) = (.internalServerError, [:], .capture())
            }
            
            // Report the error
            req.logger.report(error: error,
                              metadata: ["method": "\(req.method.rawValue)",
                                         "url": "\(req.url.string)",
                                         "userAgent": .array(req.headers["User-Agent"].map { "\($0)" })],
                              file: source.file,
                              function: source.function,
                              line: source.line)
            
            // attempt to serialize the error to json
            let body: Response.Body
            do {
                let context = ErrorResponse(error: true, reason: reason, code: status.code.description)
                
                if req.url.path.starts(with: "/api/") {
                    let encoder = try ContentConfiguration.global.requireEncoder(for: .json)
                    var byteBuffer = req.byteBufferAllocator.buffer(capacity: 0)
                    try encoder.encode(context, to: &byteBuffer, headers: &headers)
                    
                    body = .init(
                        buffer: byteBuffer,
                        byteBufferAllocator: req.byteBufferAllocator
                    )
                } else {
                    body = try await .init(
                        buffer: req.view.render("error", context).data,
                        byteBufferAllocator: req.byteBufferAllocator
                    )
                }
            } catch {
                body = .init(string: "Oops: \(String(describing: error))\nWhile encoding error: \(reason)", byteBufferAllocator: req.byteBufferAllocator)
                headers.contentType = .plainText
            }
            
            // create a Response with appropriate status
            return Response(status: status, headers: headers, body: body)
        }
    }
}
