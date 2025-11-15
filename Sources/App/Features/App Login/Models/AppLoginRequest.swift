//
//  AppLoginRequest.swift
//  swift-leeds
//
//  Created by James Sherlock on 15/11/2025.
//

import Vapor

struct AppLoginRequest: Content {
    let event: UUID?
    let email: String
    let ticket: String
}
