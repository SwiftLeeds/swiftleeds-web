//
//  SpeakerResponse.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor

struct SpeakerResponse: Content {
    let id: UUID?
    let name: String
    let biography: String
    let profileImage: String
    let twitter: String?
    let organisation: String
    let presentations: [PresentationResponse]?
}
