//
//  EventResponse.swift
//  
//
//  Created by Alex Logan on 02/08/2022.
//

import Foundation
import Vapor

struct EventResponse: Content {
    var id: UUID
    var name: String
    var date: String
    var location: String
}
