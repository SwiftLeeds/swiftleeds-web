//
//  PresentationResponse.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor

struct PresentationResponse: Content {
    let id: UUID?
    let title: String
    let synopsis: String
    let image: String?
    let speaker: SpeakerResponse?
}
