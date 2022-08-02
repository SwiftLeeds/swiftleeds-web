//
//  ScheduleResponse.swift
//  
//
//  Created by Alex Logan on 02/08/2022.
//

import Foundation
import Vapor

struct ScheduleResponse: Content {
    let event: EventResponse
    let slots: [SlotResponse]
}
