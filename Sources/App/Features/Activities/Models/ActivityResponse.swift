//
//  ActivityResponse.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor

struct ActivityResponse: Content {
    let id: UUID
    let title: String
    let subtitle: String?
    let description: String?
    let metadataURL: String?
    let image: String?
}
