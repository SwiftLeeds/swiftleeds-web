import Vapor

final class SessionizeService {
    struct SessionizeEvent: Codable {
        struct Dates: Codable {
            let startUtc: Date
            let endUtc: Date
        }
        
        let cfpLink: String
        let cfpDates: Dates
    }
    
    func loadEvent(slug: String, req: Request) async throws -> SessionizeEvent {
        guard let sessionizeKey = Environment.get("SESSIONIZE_KEY") else {
            throw Abort(.internalServerError, reason: "Missing 'SESSIONIZE_KEY' environment variable")
        }
        
        let api: URI = "https://sessionize.com/api/universal/event?slug=\(slug)"
        let headers: HTTPHeaders = [
            "X-API-KEY": sessionizeKey
        ]
        
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            return formatter.date(from: value) ?? .init()
        })
        
        let data = try await req.client.get(api, headers: headers)
        return try data.content.decode(SessionizeEvent.self, using: decoder)
    }
}
