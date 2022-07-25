//
//  GenericResponse.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor

struct GenericResponse<Response: Content>: Content {
    let data: Response
}
