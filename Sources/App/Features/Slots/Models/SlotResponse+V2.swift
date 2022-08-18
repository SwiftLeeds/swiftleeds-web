//
//  SlotResponse+V2.swift
//  
//
//  Created by Alex Logan on 18/08/2022.
//

import Foundation
import Vapor

struct SlotResponseV2: Content {
    let id: UUID
    let startTime: String
    let duration: Double
    let presentation: PresentationResponseV2?
    let activity: ActivityResponse?
}
