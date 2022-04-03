//
//  Speaker.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor

struct Speaker: Encodable, Content {
    let name: String
    let title: String
    let socialLink: String
    let imageLink: String
}
