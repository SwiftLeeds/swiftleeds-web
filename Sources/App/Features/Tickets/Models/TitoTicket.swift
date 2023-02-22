import Foundation

struct TitoTicket: Decodable {
    let first_name: String
    let last_name: String
    let company: String?
    let avatar_url: URL?
    let responses: [String: String]
}

struct TitoResponse: Decodable {
    let ticket: TitoTicket
}
