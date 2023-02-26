import Foundation

struct TitoTicket: Codable {
    let first_name: String
    let last_name: String
    let slug: String
    let company: String?
    let avatar_url: URL?
    let responses: [String: String]
}

struct TitoResponse: Decodable {
    let ticket: TitoTicket
}
