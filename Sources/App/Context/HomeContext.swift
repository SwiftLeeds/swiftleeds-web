//
//  HomeContext.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor

/// Placeholder context for the home page.
///
/// Usage:
///
///     let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22
///     let speakers: [Speaker] = Speaker.speakers // This should be populated from a database
///     return req.view.render("Home/home", HomeContext(speakers: speakers, cfpActive: Date() < cfpExpirationDate))
/// 
struct HomeContext: Content {
    var speakers: [Speaker] = []
    var cfpEnabled: Bool = false
    var presentations: [Presentation]
}
