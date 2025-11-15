//
//  AppTicketResponse.swift
//  swift-leeds
//
//  Created by James Sherlock on 15/11/2025.
//

import JWT

struct AppTicketJWTPayload: JWTPayload {
    let sub: SubjectClaim
    let iat: IssuedAtClaim
    let slug: String
    let reference: String
    let event: String
    let ticketType: String
    
    func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        
    }
}
