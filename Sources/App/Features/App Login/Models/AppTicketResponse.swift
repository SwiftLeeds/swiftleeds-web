import JWT

struct AppTicketJWTPayload: JWTPayload {
    let sub: SubjectClaim
    let iat: IssuedAtClaim
    let slug: String
    let reference: String
    let event: String
    let ticketType: String
    
    func verify(using _: some JWTKit.JWTAlgorithm) async throws {}
}
