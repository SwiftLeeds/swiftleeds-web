//
//  AppTicketResponse.swift
//  swift-leeds
//
//  Created by James Sherlock on 15/11/2025.
//

import Vapor

struct AppTicketResponse: Content {
    let slug: String
    let reference: String
    let email: String
    let ticketType: String
}
