//
//  ScheduleResponse+V2.swift
//
//
//  Created by Alex Logan on 02/08/2022.
//

import Foundation
import Vapor

struct ScheduleResponseV2: Content {
    let event: EventResponse
    let slots: [SlotResponseV2]
}
