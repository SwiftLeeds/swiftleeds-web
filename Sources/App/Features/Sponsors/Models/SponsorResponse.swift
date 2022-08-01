//
//  SponsorResponse.swift
//  
//
//  Created by Alex Logan on 01/08/2022.
//

import Foundation
import Vapor

struct SponsorResponse: Content {
    let id: UUID?
    let name: String
    let image: String?
    let url: String?
    let sponsorLevel: SponsorLevelResponse?
}

enum SponsorLevelResponse: String, Content, RawRepresentable {
    case silver, gold, platinum
}
