import Foundation

struct TitoTicket: Codable {
    struct Metadata: Codable {
        let canBookDropInSession: Bool?
    }
    
    struct Release: Codable {
        let metadata: Metadata?
    }
    
    let first_name: String
    let last_name: String
    let slug: String
    let company_name: String?
    let avatar_url: URL?
    let responses: [String: String]
    let release: Release?
    let email: String
    let reference: String
    let qr_url: String?
    
    var fullName: String {
        first_name + " " + last_name
    }
}

struct TitoResponse: Decodable {
    let ticket: TitoTicket
}
