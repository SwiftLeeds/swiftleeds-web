import Foundation
import Vapor

enum TicketTransformer {
    static func transform(_ entity: TitoTicket) -> TicketResponse {
        return .init(
            firstName: entity.first_name,
            lastName: entity.last_name,
            company: entity.company_name,
            avatarUrl: entity.avatar_url,
            responses: entity.responses
        )
    }
}
