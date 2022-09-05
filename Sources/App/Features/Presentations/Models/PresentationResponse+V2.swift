//
//  PresentationResponse+V2.swift
//  
//
//  Created by Alex Logan on 18/08/2022.
//

import Foundation
import Vapor

struct PresentationResponseV2: Content {
    let id: UUID
    let title: String
    let synopsis: String
    let image: String?
    var speakers: [SpeakerResponse] = []
    let slidoURL: String?
}
