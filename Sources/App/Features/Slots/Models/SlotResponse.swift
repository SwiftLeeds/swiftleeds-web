//
//  SlotResponse.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor

struct SlotResponse: Content {
    let id: UUID?
    let startTime: Date?
    let duration: Double
    let presentation: PresentationResponse?
    let activity: ActivityResponse?
}
