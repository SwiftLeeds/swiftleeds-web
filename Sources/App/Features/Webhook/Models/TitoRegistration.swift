import Foundation

struct TitoRegistration: Decodable {
    let id: Int
    let slug: String
    let reference: String
    let first_name: String
    let last_name: String
    let email: String
    let company_name: String?
    let test_mode: Bool
    let tickets: [Ticket]
    let event: Event
    
    var fullName: String {
        return "\(first_name) \(last_name)"
    }
    
    struct Ticket: Decodable {
        let slug: String
        let reference: String
        let release_title: String
        let first_name: String?
        let last_name: String?
        let email: String?
        let company_name: String?
        let job_title: String?
        let upgrades: [Upgrade]?
        
        var fullName: String? {
            guard let first_name, let last_name else { return nil }
            return "\(first_name) \(last_name)"
        }
        
        struct Upgrade: Decodable {
            let title: String
        }
    }

    struct Event: Decodable {
        let id: Int
        let account_slug: String
        let slug: String
        let title: String
        let url: String
    }
}

struct RegistrationResponse: Decodable {
    let ticket: TitoTicket
}
